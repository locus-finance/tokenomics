// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "../../LSLib.sol";
import "../../v2/manualWithdrawQueueFacets/libraries/DelayedSendingsQueueLib.sol";

interface ILSDepositaryFacet {
    function _initialize_LSDepositaryFacet() external;

    function stake(uint256 amount) external;

    function stakeFor(address staker, uint256 amount) external;

    function withdraw(uint256 amount, DelayedSendingsQueueLib.DueDuration dueDuration) external;

    function getReward(DelayedSendingsQueueLib.DueDuration dueDuration) external;

    function updateReward(address account) external;
}
