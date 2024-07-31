// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

/// @title A facet that implements all of the diamonds facets initialization. 
/// @author Oleg Bedrin <o.bedrin@locus.finance> - Locus Team
/// @notice The contract is meant to be utilized as a EIP2535 proxy facet. Hence it cannot be called directly and not through
/// the diamond proxy.
interface IASInitializerFacet {
    /// @notice An initializer function for Locus Token owner and starting state of the inflation.
    /// @param owner An address for the governing purposes.
    /// @param token A token that should be staked in and act as a reward.
    function initialize(
        address owner,
        address token
    ) external;
}
