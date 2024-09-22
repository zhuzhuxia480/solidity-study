// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract OtherContract{
    uint256 private _x = 0;

    event log(uint amount, uint gas);

    function getBalance() view public returns(uint256){
        return address(this).balance;
    }

    function setX(uint256 x) external payable{
        _x = x;
        if (msg.value > 0){
            emit log(msg.value, gasleft());
        }
    }

    function getX() external view returns(uint256){
        return _x;
    }
}

contract CallContract{

    function callSetX(address _Address, uint256 x) external {
        OtherContract(_Address).setX(x);
    } 

    function callGetX(OtherContract oc) external view returns(uint256){
        return oc.getX();
    }

    function callGetX2(address _Address) external view returns(uint256){
        OtherContract oc = OtherContract(_Address);
        return oc.getX();
    }

    function setXTransferETH(address _address, uint256 x) external payable{
        OtherContract(_address).setX{value:msg.value}(x);
    }
}