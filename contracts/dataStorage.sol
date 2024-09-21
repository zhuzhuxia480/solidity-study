// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract DataStorage{

    uint[] public x = [1,3,4];
    
    function fStorage() public{
        uint[] storage xStorage = x;
        xStorage[0] = 100;
    }

    function fMemory() public view {
        uint[] memory xMem = x;
        xMem[0] = 111;
    }
}