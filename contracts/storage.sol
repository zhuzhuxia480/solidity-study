// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;
contract Variables{
    function global() public view returns(address, uint, bytes memory){
        return (msg.sender, block.number, msg.data);
    }


}