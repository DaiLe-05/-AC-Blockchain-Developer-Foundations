// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract Welcome {
    string public greeting;

    constructor(string memory _greeting) {
        greeting = _greeting;
    }

    function getGreeting() public view returns (string memory) {
        return greeting;
    }
}