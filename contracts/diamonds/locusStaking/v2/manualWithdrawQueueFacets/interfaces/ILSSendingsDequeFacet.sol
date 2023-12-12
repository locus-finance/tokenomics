// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "../libraries/WithdrawalsQueueLib.sol";

interface ILSSendingsDequeFacet {
    function addDelayedSending(
        address sendingToken,
        address receiver,
        uint256 amount,
        WithdrawalsQueueLib.DueDuration dueToDuration,
        bool isStakingOrReward
    ) external;

    function getDelayedSending(uint256 index) external view returns (WithdrawalsQueueLib.DelayedSending memory);
    
    function getDequeSize() external view returns (uint256);

    function processQueue(bool isStakingOrRewardTokenUtilized) external;
}
