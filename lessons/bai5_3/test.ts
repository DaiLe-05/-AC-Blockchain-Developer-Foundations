import { ethers } from "ethers";
import * as fs from "fs";
import * as path from "path";

/**
 * Bài Tập 5.3 – Giao tiếp với Smart Contract qua ABI
 *
 * Đọc giá trị `getCount()` của contract Counter (tái sử dụng từ Bài 5.2)
 * thông qua ABI + địa chỉ contract đã deploy.
 *
 * Mặc định chạy trên Hardhat localhost.
 * Để chuyển sang Sepolia chỉ cần đổi biến môi trường, KHÔNG cần sửa logic:
 *   RPC_URL=https://eth-sepolia.public.blastapi.io
 *   DEPLOYMENT_NETWORK=sepolia        (đọc address từ deployments/sepolia/Counter.json)
 *   hoặc CONTRACT_ADDRESS=0x...       (chỉ định trực tiếp địa chỉ đã deploy)
 */

// ABI của Counter: cần `getCount()` để đọc, khai báo `increment()` cho đầy đủ.
const COUNTER_ABI = [
  "function getCount() public view returns (uint256)",
  "function increment() public",
];

// ---- Cấu hình network (có thể override bằng biến môi trường) ----
const RPC_URL = process.env.RPC_URL ?? "http://127.0.0.1:8545";
const DEPLOYMENT_NETWORK = process.env.DEPLOYMENT_NETWORK ?? "localhost";

/**
 * Lấy địa chỉ contract thật từ deployment artifacts của Bài 5.2.
 * Ưu tiên CONTRACT_ADDRESS nếu được cung cấp qua biến môi trường.
 */
function loadDeployedAddress(network: string): string {
  if (process.env.CONTRACT_ADDRESS) {
    return process.env.CONTRACT_ADDRESS;
  }

  const artifactPath = path.join(
    __dirname,
    "..",
    "bai5_2",
    "deployments",
    network,
    "Counter.json"
  );

  if (!fs.existsSync(artifactPath)) {
    throw new Error(
      `Không tìm thấy deployment artifact tại: ${artifactPath}\n` +
        `Hãy deploy Counter trước (xem lessons/bai5_2) hoặc set biến môi trường CONTRACT_ADDRESS.`
    );
  }

  const artifact = JSON.parse(fs.readFileSync(artifactPath, "utf-8")) as {
    address?: string;
  };

  if (!artifact.address) {
    throw new Error(`Artifact ${artifactPath} không chứa trường "address".`);
  }

  return artifact.address;
}

async function main() {
  // 1. Lấy & kiểm tra địa chỉ contract
  const contractAddress = loadDeployedAddress(DEPLOYMENT_NETWORK);

  if (!ethers.isAddress(contractAddress)) {
    throw new Error(`Địa chỉ contract không hợp lệ: ${contractAddress}`);
  }

  // 2. Khởi tạo Ethers.js JsonRpcProvider
  const provider = new ethers.JsonRpcProvider(RPC_URL);

  // 3. Kiểm tra kết nối RPC
  let network;
  try {
    network = await provider.getNetwork();
  } catch (error) {
    throw new Error(
      `Không thể kết nối tới RPC ${RPC_URL}. Hãy chắc chắn Hardhat node đang chạy ` +
        `(npx hardhat node) hoặc RPC URL hợp lệ.\nChi tiết: ${
          (error as Error).message
        }`
    );
  }

  console.log(`✅ Kết nối RPC: ${RPC_URL} (chainId: ${network.chainId})`);

  // 4. Kiểm tra có contract thực sự tồn tại tại địa chỉ này không
  const code = await provider.getCode(contractAddress);
  if (code === "0x") {
    throw new Error(
      `Không có contract nào tại địa chỉ ${contractAddress} trên network này. ` +
        `Có thể bạn đang kết nối sai network hoặc contract chưa được deploy.`
    );
  }

  // 5. Kết nối tới contract bằng địa chỉ + ABI (chỉ cần provider vì đây là hàm view)
  const contract = new ethers.Contract(contractAddress, COUNTER_ABI, provider);
  console.log(`✅ Contract Counter: ${contractAddress}`);

  // 6. Gọi getCount() và in ra console (KHÔNG gọi increment để không đổi trạng thái)
  const count: bigint = await contract.getCount();
  console.log("Current count is:", count.toString());
}

main().catch((error) => {
  console.error("❌ Lỗi:", (error as Error).message ?? error);
  process.exitCode = 1;
});
