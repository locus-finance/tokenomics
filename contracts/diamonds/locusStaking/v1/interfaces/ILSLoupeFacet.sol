// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

interface ILSLoupeFacet {
    function lastTimeRewardApplicable() external view returns (uint256);

    function rewardPerToken() external view returns (uint256);

    function earned(address account) external view returns (uint256);

    function getRewardForDuration() external view returns (uint256);

    function getCurrentFeeBps() external view returns (uint256 feeBps);
}
