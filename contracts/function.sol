// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;
contract MyFunction{
    uint256 public num = 1;

    //function (<params>) {internal|external|privite|public} [pure|view|payable] [return ()]

    //any function need Visibility
    //add can read and write num
    function add() public {
        num += 1;
    }

    //addPure can not read or wirte num
    function addPure(uint256 new_num) public pure {
        new_num += 1;
    }

    //addView can read read num only
    function addView(uint256 new_num) public view {
        new_num = num + 1;
    }

    //only internal call
    function minus() internal {
        num -= 1;
    }

    //external call
    function minusCall() external {
        minus();
    }

    //
    function testCall() internal {
        //must use this.
        this.minusCall();
        //don`t need this.
        addPure(1);
        addView(1);
    }
}