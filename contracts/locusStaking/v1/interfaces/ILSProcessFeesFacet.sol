// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface ILSProcessFeesFacet {
    function getFeesAccountedRewardAndDistributeFees(
        uint256 reward,
        IERC20 rewardsToken
    ) external returns (uint256 feesSubstractedReward);
}
