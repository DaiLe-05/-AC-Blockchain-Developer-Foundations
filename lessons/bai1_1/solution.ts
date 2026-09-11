
export type Block = {
  index: number;
  timestamp: string;
  transactions: any[];
  previous_hash: string;
  current_hash: string;
};

// ✍️ TODO: Viết hàm tại đây
import crypto from "crypto";

export function isValidBlock(block: Block): boolean {
    const value =
        block.index +
        block.timestamp +
        JSON.stringify(block.transactions) +
        block.previous_hash;

    const hash = crypto
        .createHash("sha256")
        .update(value)
        .digest("hex");

    return hash === block.current_hash;
}
