// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

interface ILSManagementFacet {
    function notifyRewardAmount(uint256 reward) external;

    function recoverTokens(address tokenAddress, uint256 tokenAmount) external;

    function setRewardsDuration(uint256 _rewardsDuration) external;

    function setAutoLockDuration(uint256 _autoLockDuration) external;
}
