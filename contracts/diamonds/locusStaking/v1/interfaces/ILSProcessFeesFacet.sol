// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

import "../../LSLib.sol";

interface ILSProcessFeesFacet {
    function processRewardSending(address staker, uint256 reward, LSLib.DueDuration dueDuration) external;

    function processWithdrawalSending(address staker, uint256 amount, LSLib.DueDuration dueDuration) external;
}
