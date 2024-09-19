// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;
contract Modifier{

    address public owner;

    constructor(address _owner){
        owner = _owner;
    }

    modifier OnlyOwner{
        require(msg.sender == owner);
        _;
    }

    function changeOwner(address newOwner) public OnlyOwner {
        owner = newOwner;
    }
}