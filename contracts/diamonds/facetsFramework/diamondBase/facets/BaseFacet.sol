// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

import "../libraries/PausabilityLib.sol";
import "../libraries/InitializerLib.sol";
import "../libraries/RolesManagementLib.sol";

/// @title A base facet that establishes some important modifiers and functions to must have for each facet. 
/// @author Oleg Bedrin <o.bedrin@locus.finance> - Locus Team
/// @notice The contract is meant to be utilized as a EIP2535 proxy facet. Hence it cannot be called directly and not through
/// the diamond proxy.
abstract contract BaseFacet is Initializable {
    error DelegatedCallsOnly();
    
    /// @dev An address of the actual contract instance. The original address as part of the context.
    address internal immutable __self = address(this);

    /// @dev Throws if called within a function that were called by CALL.
    function enforceDelegatedOnly() internal view {
        if (address(this) == __self || !InitializerLib.get().initialized) {
            revert DelegatedCallsOnly();
        }
    }

    /// @dev Forces to use DELEGETACALL on the function it's applied to. 
    /// The body of the modifier is copied into a faucet sources, so to make a small gas optimization - 
    /// the modifier uses an internal function call.
    modifier delegatedOnly {
        enforceDelegatedOnly();
        _;
    }

    /// @dev It makes the function under it callable only by other facet inside the same diamond it belongs to.
    modifier internalOnly {
        RolesManagementLib.enforceSenderRole(RolesManagementLib.INTERNAL_ROLE);
        _;
    }
}