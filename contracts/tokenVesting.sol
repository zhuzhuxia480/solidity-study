// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21 <0.9;

import "./erc20.sol";

contract TokenVesting {

    event ERC20Released(address indexed token, uint256 amount);

    mapping(address => uint256) public erc20Released;
    address public immutable beneficiary;
    uint256 public immutable start;
    uint256 public immutable duration;

    constructor(address beneficiaryAddress, uint256 durationSeconds){
        require(beneficiaryAddress != address(0), "beneficiary is zero address");
        beneficiary = beneficiaryAddress;
        duration = durationSeconds;
    }

    function release(address token) public {
        uint256 releasable = vestedAmount(token, uint256(block.timestamp)) - erc20Released[token];
        erc20Released[token] += releasable;
        emit ERC20Released(token, releasable);
        IERC20(token).transfer(beneficiary, releasable);
    }

    function vestedAmount(address token, uint256 timestamp) public view returns (uint256) {
        uint256 totalAllocation = IERC20(token).balanceOf(address(this)) + erc20Released[token];
        if (timestamp < start) {
            return 0;
        } else if (timestamp > start + duration) {
            return totalAllocation;
        } else {
            return (totalAllocation * (timestamp - start)) / duration;
        }
    }
}

