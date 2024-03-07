// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

interface IASInitializerFacet {
    /// @notice An initializer function for Locus Token owner and starting state of the inflation.
    /// @param owner An address for the governing purposes.
    /// @param token A token that should be staked in and act as a reward.
    function initialize(
        address owner,
        address token
    ) external;

    function migrateBalance(address who, uint256 amount) external;
}
