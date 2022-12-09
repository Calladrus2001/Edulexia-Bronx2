// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

contract MyContract {
    address private owner;
    mapping(string => int) public balances;

    constructor() {
        owner = msg.sender;
    }

    function createNewUser(string memory _uid) public {
        balances[_uid] = 1000;
    }

    function createNewAudioFile(string memory _uid) public {
        require(balances[_uid] >= 50, "Insufficient balance");
        balances[_uid] -= 50;
    }

    function getBalance(string memory _uid) public view returns (int) {
        return balances[_uid];
    }

    function evaluateYourself(string memory _uid) public {
        require(balances[_uid] >= 20, "Insufficient balance");
        balances[_uid] -= 20;
    }
}
