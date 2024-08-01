// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "../../LSLib.sol";

/// @title A facet that implements view functions of the diamond.
/// @author Oleg Bedrin <o.bedrin@locus.finance> - Locus Team
/// @notice The contract is meant to be utilized as a EIP2535 proxy facet. Hence it cannot be called directly and not through
/// the diamond proxy.
interface ILSLoupeFacet {
    /// @notice Gives all primitive internal variables of the diamond.
    /// @return `Primitives` struct.
    function getPrimitives() external view returns (LSLib.Primitives memory);

    /// @notice Returns timestamp when last time the reward was provided to distribute to users.
    /// @return A timestamp.
    function lastTimeRewardApplicable() external view returns (uint256);

    /// @notice Returns amount of rewards tokens worth of 1 staking token.
    /// @return An amount of tokens.
    function rewardPerToken() external view returns (uint256);

    /// @notice Returns an amount of rewards tokens earned by an `account`.
    /// @param account An account to check.
    /// @return Amount of tokens earned by the account.
    function earned(address account) external view returns (uint256);

    /// @notice Returns a total amount rewards earned since the diamond deployment.
    /// @return An amount of tokens.
    function getTotalReward() external view returns (uint256);

    /// @notice Returns a total amount rewards earned throughout of staking cycle.
    /// @return An amount of tokens.
    function getRewardForDuration() external view returns (uint256);

    /// @notice Returns an APR with constraint (reward rate is unchanging throughout the staking cycle).
    /// The precision of the APR equals to `10**<decimals of staking token>`.
    /// @return APR
    function getAPR() external view returns (uint256);

    /// @notice Returns an APR with the same constraint as is `getAPR`, but reward rate and staking cycle are variables.
    /// @param rewardRate A rate with which the rewards are accumulated.
    /// @param rewardDuration A staking cycle.
    /// @return Projected APR.
    function getProjectedAPR(
        uint256 rewardRate,
        uint256 rewardDuration
    ) external view returns (uint256);

    /// @notice Returns an amount of tokens earned per 1 staking token throughout 1 staking cycle
    /// with actual but constant reward rate.
    /// @return An amount of tokens.
    function getAPRInAbsoluteValue() external view returns (uint256);

    /// @notice Returns currently total staked tokens amount.
    /// @return An amount of tokens.
    function totalSupply() external view returns (uint256);

    /// @notice Returns a staked deposit of some entity.
    /// @param account An entity to check.
    /// @return An amount of tokens staked.
    function balanceOf(address account) external view returns (uint256);

    /// @notice Returns EIP20-like precision.
    /// @return Decimals.
    function decimals() external view returns (uint8);
}
