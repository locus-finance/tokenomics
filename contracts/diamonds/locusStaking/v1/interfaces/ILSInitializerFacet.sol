// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

/// @title A facet that implements the diamond initalization.
/// @author Oleg Bedrin <o.bedrin@locus.finance> - Locus Team
/// @notice The contract is meant to be utilized as a EIP2535 proxy facet. Hence it cannot be called directly and not through
/// the diamond proxy.
interface ILSInitializerFacet {
    /// @notice An initalizer function for the diamond.
    /// @param owner Owner of the diamond operations.
    /// @param rewardDistributor An entity who would be able to provide rewards.
    /// @param rewardsToken Token address to act as a reward token.
    /// @param stakingToken Token address to act as a staking token.
    function initialize(
        address owner,
        address rewardDistributor,
        address rewardsToken,
        address stakingToken
    ) external;

    /// @notice Initializes OZ dependencies of the depositary facet. Can only be called by
    /// `OWNER_ROLE` bearer.
    function prepareDepositary() external;

    /// @notice Setter for token representation of staking deposit.
    /// @dev NOT UTILIZED ANYWHERE CURRENTLY. Could only be set by `OWNER_ROLE` bearer.
    /// @param wrappedStLocusToken Address of the EIP20 wrapper.
    function setWrappedStakingLocus(address wrappedStLocusToken) external;
}
