// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title Bài 4.3 – Voting Smart Contract
/// @notice Admin tạo danh sách ứng viên, mỗi người chỉ được vote 1 lần cho 1 ứng viên
contract Voting {
    // ---------------------------------------------------------
    // 1. STRUCT: gom nhóm dữ liệu của một ứng viên
    // ---------------------------------------------------------
    struct Candidate {
        string name; // tên ứng viên
        uint voteCount; // số phiếu đã nhận
    }

    // ---------------------------------------------------------
    // 2. MAPPING: candidates[id] = thông tin ứng viên
    //    Ứng viên chưa tồn tại có name = "" và voteCount = 0
    // ---------------------------------------------------------
    mapping(uint => Candidate) public candidates;

    // ---------------------------------------------------------
    // 3. MAPPING: hasVoted[địa chỉ ví] = đã vote hay chưa
    // ---------------------------------------------------------
    mapping(address => bool) public hasVoted;

    // Địa chỉ owner (người deploy contract)
    address public owner;

    // Số lượng ứng viên đã được tạo
    uint public candidatesCount;

    // 5. EVENT: phát ra mỗi lần vote thành công
    event Voted(address indexed voter, uint indexed candidateId);

    // 4. MODIFIER: chỉ owner được phép gọi
    modifier onlyOwner() {
        require(msg.sender == owner, "Voting: chi owner moi duoc phep");
        _;
    }

    // Người deploy trở thành owner
    constructor() {
        owner = msg.sender;
    }

    // Chỉ owner được tạo ứng viên mới
    function addCandidate(string memory name) public onlyOwner {
        require(bytes(name).length > 0, "Voting: ten ung vien khong duoc rong");

        // id bắt đầu từ 0, sau đó tăng lên
        candidates[candidatesCount] = Candidate({
            name: name,
            voteCount: 0
        });
        candidatesCount++;
    }

    // Người dùng vote cho ứng viên theo id
    // Mỗi ví chỉ được vote 1 lần
    function vote(uint candidateId) public {
        require(!hasVoted[msg.sender], "Voting: ban da vote roi");
        require(candidateId < candidatesCount, "Voting: ung vien khong ton tai");

        hasVoted[msg.sender] = true;
        candidates[candidateId].voteCount++;

        emit Voted(msg.sender, candidateId);
    }

    // Đọc thông tin ứng viên theo id
    function getCandidate(uint candidateId)
        public
        view
        returns (string memory name, uint voteCount)
    {
        require(candidateId < candidatesCount, "Voting: ung vien khong ton tai");
        Candidate storage c = candidates[candidateId];
        return (c.name, c.voteCount);
    }

    // Kiểm tra một địa chỉ đã vote hay chưa
    function hasAddressVoted(address voter) public view returns (bool) {
        return hasVoted[voter];
    }
}
