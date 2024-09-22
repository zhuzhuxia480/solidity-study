// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract Fallback{
    event receivedCalled(address sender, uint value);
    event fallbackCalled(address sender, uint value);
    
    constructor() payable{
        
    }
    receive() external payable{
        emit receivedCalled(msg.sender, msg.value);
    }
    
    fallback() external payable{
        emit fallbackCalled(msg.sender, msg.value);
    }
}