// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "../interfaces/IPausable.sol";
import "../libraries/PausabilityLib.sol";
import "../libraries/RolesManagementLib.sol";
import "./BaseFacet.sol";

/// @title A base facet that establishes the pausability functionality. 
/// @author Oleg Bedrin <o.bedrin@locus.finance> - Locus Team
/// @notice The contract is meant to be utilized as a EIP2535 proxy facet. Hence it cannot be called directly and not through
/// the diamond proxy.
contract PausabilityFacet is IPausable, BaseFacet {
    /// @dev Reverts function if it is in paused state.
    modifier whenNotPaused {
        if (PausabilityLib.get().paused) {
            revert PausabilityLib.OnlyWhenNotPaused(); 
        }
        _;
    }
    
    /// @inheritdoc IPausable
    function paused() external view override delegatedOnly returns (bool) {
        return PausabilityLib.get().paused;
    }

    /// @inheritdoc IPausable
    function pause() external override delegatedOnly {
        RolesManagementLib.enforceSenderRole(RolesManagementLib.PAUSER_ROLE);
        PausabilityLib.get().paused = true;
    }

    /// @inheritdoc IPausable
    function unpause() external override delegatedOnly {
        RolesManagementLib.enforceSenderRole(RolesManagementLib.PAUSER_ROLE);
        PausabilityLib.get().paused = false;
    }
}