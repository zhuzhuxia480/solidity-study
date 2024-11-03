// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21 <0.9;

contract UUPSProxy{
    address public implementation;
    address public admin;
    string public words;

    constructor(address _implementation) {
        admin = msg.sender;
        implementation = _implementation;
    }

    fallback() external payable { 
        (bool success, bytes memory data) = implementation.delegatecall(msg.data);
    }

    receive() external payable { }
}

contract UUPS1{
    address public implementation;
    address public admin;
    string public words;

    function foo() external {
        words = "old";
    }

    function upgrade(address newImplementaion) external {
        require(msg.sender == admin);
        implementation = newImplementaion;
    }
}

contract UUPS2{
    address public implementation;
    address public admin;
    string public words;

    function foo() external {
        words = "new";
    }
    
    function upgrade(address newImplementaion) external {
        require(msg.sender == admin);
        implementation = newImplementaion;
    }
}