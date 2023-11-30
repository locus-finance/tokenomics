// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

interface ILSProcessFeesFacet {
    function getFeesAccountedAmountAndDistributeFees(
        address staker,
        uint256 reward,
        IERC20Metadata rewardsToken
    ) external returns (uint256 feesSubstractedReward);
}
