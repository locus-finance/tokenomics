// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

import "../../v2/libraries/WithdrawalsQueueLib.sol";

interface ILSProcessFeesFacet {
    function processRewardSending(
        address staker,
        uint256 reward,
        WithdrawalsQueueLib.DueDuration dueDuration
    ) external;

    function processWithdrawalSending(
        address staker,
        uint256 amount,
        WithdrawalsQueueLib.DueDuration dueDuration
    ) external;
}
