// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

interface ILSManagementFacet {
    function notifyRewardAmount(uint256 reward) external;

    function recoverTokens(address tokenAddress, uint256 tokenAmount) external;

    function setRewardsDuration(uint256 _rewardsDuration) external;
}
