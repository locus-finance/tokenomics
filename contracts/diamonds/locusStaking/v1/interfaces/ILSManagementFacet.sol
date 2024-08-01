// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

/// @title A facet that implements managemental functionality of the diamond. 
/// Specifically: rewards management, setting duration of the staking cycle, recovering stuck tokens that
/// are allowed to be extracted.
/// @author Oleg Bedrin <o.bedrin@locus.finance> - Locus Team
/// @notice The contract is meant to be utilized as a EIP2535 proxy facet. Hence it cannot be called directly and not through
/// the diamond proxy.
interface ILSManagementFacet {
    /// @notice Transfers from `msg.sender` (if they're a bearer of `REWARD_DISTRIBUTOR_ROLE`) a reward for the diamond users
    /// and starts a distribution resetting the staking cycle.
    /// @param reward An amount of tokens to be distributed among the users group.
    function notifyRewardAmount(uint256 reward) external;

    /// @notice Allows bearer of `OWNER_ROLE` to recover stucked tokens.
    /// @param tokenAddress An address of stucked token.
    /// @param tokenAmount An amount of stucked tokens.
    function recoverTokens(address tokenAddress, uint256 tokenAmount) external;

    /// @notice Sets a duration for staking cycle. Callable only by `OWNER_ROLE`.
    /// @param _rewardsDuration A duration of staking cycle in seconds.
    function setRewardsDuration(uint256 _rewardsDuration) external;
}
