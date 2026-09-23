// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract VotingEligibility {
    // Tuổi tối thiểu để đủ điều kiện đi bầu cử
    uint public minAge = 18;

    // Địa chỉ deploy contract (chỉ người này được cập nhật minAge)
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    // Kiểm tra điều kiện: age >= minAge -> true, ngược lại -> false
    // view: chỉ đọc state (minAge), không sửa state
    function checkEligibility(uint age) public view returns (bool) {
        if (age >= minAge) {
            return true;
        } else {
            return false;
        }
    }

    // Chỉ người deploy được gọi, sau đó cập nhật minAge
    function updateMinAge(uint newMinAge) public {
        require(msg.sender == owner, "VotingEligibility: only owner can update minAge");
        minAge = newMinAge;
    }
}
