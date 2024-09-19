// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract Array{

    uint[] a;
    function ArrayPush() public returns(uint) {
        uint[3] memory arr = [uint(1),3,4];
        a = arr;
        a.push(2);
        return arr.length;
    }
}