// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "../../LSLib.sol";

interface ILSLoupeFacet {
    function getPrimitives() external view returns (LSLib.Primitives memory);
    
    function lastTimeRewardApplicable() external view returns (uint256);

    function rewardPerToken() external view returns (uint256);

    function earned(address account) external view returns (uint256);

    function getTotalReward() external view returns (uint256);

    function getRewardForDuration() external view returns (uint256);

    function getAPR() external view returns (uint256);

    function getProjectedAPR(uint256 rewardRate, uint256 rewardDuration) external view returns (uint256);

    function getAPRInAbsoluteValue() external view returns (uint256);
}
