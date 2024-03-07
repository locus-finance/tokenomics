// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "../../../locusStaking/v2/manualWithdrawQueueFacets/libraries/DelayedSendingsQueueLib.sol";

interface IASDepositaryFacet {
    event Staked(uint256 indexed amount);
    event Withdrawn(uint256 indexed amount);
    event RewardAdded(uint256 indexed amount);

    function stake(uint256 amount) external;

    function withdraw(uint256 amount, DelayedSendingsQueueLib.DueDuration dueDuration) external;

    function notifyRewardAmount(uint256 amount) external;
}
