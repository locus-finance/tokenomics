// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

interface IASInitializerFacet {
    /// @notice An initializer function for Locus Token owner and starting state of the inflation.
    /// @param owner An address who can end and rule autocracy, and mint inflation of LCS tokens.
    function initialize(address owner) external;
}
