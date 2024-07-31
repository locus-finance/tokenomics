// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "../libraries/RolesManagementLib.sol";
import "../interfaces/IRolesManagement.sol";
import "./BaseFacet.sol";

/// @title A base facet that establishes the basic roles functionality.
/// @author Oleg Bedrin <o.bedrin@locus.finance> - Locus Team
/// @notice The contract is meant to be utilized as a EIP2535 proxy facet. Hence it cannot be called directly and not through
/// the diamond proxy.
contract RolesManagementFacet is IRolesManagement, BaseFacet {
    error UnequalLengths(uint256 length1, uint256 length2);

    /// @inheritdoc IRolesManagement
    function grantRoles(
        address[] calldata entities,
        bytes32[] calldata roles
    ) external override delegatedOnly {
        RolesManagementLib.enforceSenderRole(RolesManagementLib.OWNER_ROLE);
        if (entities.length != roles.length) {
            revert UnequalLengths(entities.length, roles.length);
        }
        for (uint256 i = 0; i < entities.length; i++) {
            RolesManagementLib.grantRole(entities[i], roles[i]);
        }
    }

    /// @inheritdoc IRolesManagement
    function revokeRoles(
        address[] calldata entities,
        bytes32[] calldata roles
    ) external override delegatedOnly {
        RolesManagementLib.enforceSenderRole(RolesManagementLib.OWNER_ROLE);
        if (entities.length != roles.length) {
            revert UnequalLengths(entities.length, roles.length);
        }
        for (uint256 i = 0; i < entities.length; i++) {
            RolesManagementLib.revokeRole(entities[i], roles[i]);
        }
    }

    /// @inheritdoc IRolesManagement
    function grantRole(
        address who,
        bytes32 role
    ) public override delegatedOnly {
        RolesManagementLib.enforceSenderRole(RolesManagementLib.OWNER_ROLE);
        RolesManagementLib.grantRole(who, role);
    }

    /// @inheritdoc IRolesManagement
    function revokeRole(
        address who,
        bytes32 role
    ) public override delegatedOnly {
        RolesManagementLib.enforceSenderRole(RolesManagementLib.OWNER_ROLE);
        RolesManagementLib.revokeRole(who, role);
    }

    /// @inheritdoc IRolesManagement
    function hasRole(
        address who,
        bytes32 role
    ) external view override delegatedOnly returns (bool) {
        return RolesManagementLib.get().roles[role][who];
    }
}
