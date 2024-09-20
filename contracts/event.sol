// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;
contract Event{

    mapping (address => uint256) public _balances;

    event Transfer(address indexed from, address indexed to, uint256 token);

    function _transfer(address from, address to, uint256 token) public {
        _balances[from] =1000000;
        _balances[from] -= token;
        _balances[to] += token;
        emit Transfer(from, to, token);
    }
}