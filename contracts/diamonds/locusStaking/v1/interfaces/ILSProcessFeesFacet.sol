// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

import "../../v2/manualWithdrawQueueFacets/libraries/DelayedSendingsQueueLib.sol";

interface ILSProcessFeesFacet {
    function processRewardSending(
        address staker,
        uint256 reward,
        DelayedSendingsQueueLib.DueDuration dueDuration
    ) external;

    function processWithdrawalSending(
        address staker,
        uint256 amount,
        DelayedSendingsQueueLib.DueDuration dueDuration
    ) external;
}
