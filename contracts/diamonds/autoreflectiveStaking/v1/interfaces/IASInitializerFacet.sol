// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

interface IASInitializerFacet {
    /// @notice An initializer function for Locus Token owner and starting state of the inflation.
    /// @param owner An address for the governing purposes.
    /// @param initialRewardAmount An amount that would be distributed to the stakers.
    function initialize(address owner, uint256 initialRewardAmount) external;
}
