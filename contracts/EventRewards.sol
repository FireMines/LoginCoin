// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "./CoinPool.sol";

contract EventRewards {
    CoinPool public coinPool;
    mapping(address => bool) public eventAttendees;
    uint256 public rewardAmount;

    constructor(address _coinPoolAddress, uint256 _initialRewardAmount) {
        coinPool = CoinPool(_coinPoolAddress);
        rewardAmount = _initialRewardAmount;
    }

    function rewardAttendance(address attendee) public {
        require(!eventAttendees[attendee], "Attendee has already been rewarded");
        eventAttendees[attendee] = true;
        coinPool.distributeCoins(attendee, rewardAmount);
    }

    function setRewardAmount(uint256 newRewardAmount) public {
        rewardAmount = newRewardAmount;
    }
}
