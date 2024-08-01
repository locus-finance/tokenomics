// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

import "../../v2/manualWithdrawQueueFacets/libraries/DelayedSendingsQueueLib.sol";

/// @title A facet that implements creation of delayed sendings of either rewards or withdrawals depending on what is staking.
/// Governance token or any other EIP20-compatible token.
/// @author Oleg Bedrin <o.bedrin@locus.finance> - Locus Team
/// @notice The contract is meant to be utilized as a EIP2535 proxy facet. Hence it cannot be called directly and not through
/// the diamond proxy.
interface ILSProcessFeesFacet {
    /// @notice Either creates delayed sending of rewards or just sends the rewards immediately, 
    /// depends on what token is staking: Governance token - sends without delay, other - sends with delay.
    /// @param staker A staker to which the rewards should be sent.
    /// @param reward An amount of rewards to be sent.
    /// @param dueDuration Duration code if the rewards are sent with delay.
    function processRewardSending(
        address staker,
        uint256 reward,
        DelayedSendingsQueueLib.DueDuration dueDuration
    ) external;

    /// @notice Either creates delayed sending of withdrawal or just withdraws the deposit immediately,
    /// depends on what token is staking: Governance token - sends with delay, other - sends without delay.
    /// @param staker A staker to which the withdrawal should be sent.
    /// @param amount An amount of withdrawal to be sent.
    /// @param dueDuration Duration code if the withdrawal is sent with delay. 
    function processWithdrawalSending(
        address staker,
        uint256 amount,
        DelayedSendingsQueueLib.DueDuration dueDuration
    ) external;
}
