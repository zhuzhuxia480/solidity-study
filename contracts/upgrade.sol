// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21 <0.9;

contract SimpleUpgrade {
    address public implementation;
    address public admin;
    string public words;

    constructor(address _implementation){
        admin = msg.sender;
        implementation = _implementation;
    }

    fallback() external payable { 
        (bool success, bytes memory data) = implementation.delegatecall(msg.data);
    }

    function upgrade(address newImplementation) external{
        require(admin == msg.sender);
        implementation = newImplementation;
    }
}


contract Logic1 {
    address public implementation;
    address public admin;
    string public words;

    function foo() external {
        words = "old";
    }
}

contract Logic2 {
    address public implementation;
    address public admin;
    string public words;

    function foo() external {
        words = "new";
    }
}