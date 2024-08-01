// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "../../LSLib.sol";
import "../../v2/manualWithdrawQueueFacets/libraries/DelayedSendingsQueueLib.sol";

/// @title A facet that implements the depositary logic for users.
/// @author Oleg Bedrin <o.bedrin@locus.finance> - Locus Team
/// @notice The contract is meant to be utilized as a EIP2535 proxy facet. Hence it cannot be called directly and not through
/// the diamond proxy.
interface ILSDepositaryFacet {
    /// @notice An internal diamond-wise view function that initializes OZ dependencies of the facet.
    /// @dev MIND THAT THIS SHOULD BE THE ONLY SMART CONTRACT (MEANING REENTRANCY GUARD) FROM OZ LIB THAT
    /// IS TO BE UTILIZIED IN THIS DIAMOND.
    function _initialize_LSDepositaryFacet() external;

    /// @notice Stakes a certain amount of staking token for `msg.sender`.
    /// @param amount An amount of tokens to stake.
    function stake(uint256 amount) external;

    /// @notice Stakes a certain amount of staking token for `sender`.
    /// @dev Could be called only by authorized entity.
    /// @param staker A staker address for the staking.
    /// @param amount An amount of tokens to stake.
    function stakeFor(address staker, uint256 amount) external;

    /// @notice Allows to perform a withdrawal for `msg.sender`.
    /// @param amount An amount of tokens to withdraw.
    /// @param dueDuration A code of time duration interval to expect withdrawn funds after.
    function withdraw(
        uint256 amount,
        DelayedSendingsQueueLib.DueDuration dueDuration
    ) external;

    /// @notice Allows to acquire earned rewards from staking by `msg.sender`.
    /// @param dueDuration A code of time duration interval to expect earned funds after.
    function getReward(
        DelayedSendingsQueueLib.DueDuration dueDuration
    ) external;

    /// @notice Allows to update rewards gaining math for an account.
    /// @param account An account to update rewards gaining math for.
    function updateReward(address account) external;
}
