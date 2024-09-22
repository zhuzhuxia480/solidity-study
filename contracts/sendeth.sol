// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

//three ways to send eth
//1. transfer: 2300 gas, revert
//2. send: 2300 gas, return bool
//3. call: all gas, return (bool, data)

error SendFailed();
error CallFailed();

contract SendETH{
    constructor() payable{

    }

    function transferETH(address payable _to, uint256 amount) external payable {
        _to.transfer(amount);
    }

    function sendETH(address payable _to, uint256 amount) external payable{
        bool ret = _to.send(amount);
        if (!ret){
            revert SendFailed();
        }
    }

    function callETH(address payable _to, uint256 amount) public payable{
        (bool success,) = _to.call{value: amount}("");
        if (!success){
            revert CallFailed();
        }
    }
    

}


contract ReceiveETH{
    event log(uint amount, uint gas);
    receive() external payable{
        emit log(msg.value, gasleft());
    }

    function getBalance() public view returns(uint){
        return address(this).balance;
    }
}