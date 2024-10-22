// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21 <0.9;

import "./ERC20.sol";

contract TokenLocker {
    event TokenLockStart(address indexed beneficiary, address indexed token, uint256 startTime, uint256 lockTime);
    event Release(address indexed beneficiary, address indexed token, uint256 releaseTime, uint256 amount);

    IERC20 public immutable token;
    address public immutable beneficiary;
    uint256 public immutable lockTime;
    uint256 public immutable startTime;

    constructor(IERC20 token_, address beneficiary_, uint256 lockTime_) {
        require(lockTime > 0, "lock time should greater than 0");
        token = token_;
        beneficiary = beneficiary_;
        lockTime = lockTime_;
        startTime = block.timestamp;
        emit TokenLockStart(beneficiary, address(token), block.timestamp, lockTime_);
    }

    function Realse() public {
        require(block.timestamp >= startTime + lockTime, "current time is before release time");
        uint256 amount = token.balanceOf(address(this));
        require(amount > 0, "no tokens to release");
        token.transfer(beneficiary, amount);
        emit Release(msg.sender, address(token), block.timestamp, amount);
    }

}