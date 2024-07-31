// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

/// @title A base facet that establishes the basic roles functionality.
/// @author Oleg Bedrin <o.bedrin@locus.finance> - Locus Team
/// @notice The contract is meant to be utilized as a EIP2535 proxy facet. Hence it cannot be called directly and not through
/// the diamond proxy.
interface IRolesManagement {
    /// @notice Grants a group of roles (OZ AccessControl like) to a group of entities.
    /// @param entities The entities.
    /// @param roles The roles.
    function revokeRoles(
        address[] calldata entities,
        bytes32[] calldata roles
    ) external;

    /// @notice Revokes from a group of entities a group of roles.
    /// @param entities The entities.
    /// @param roles The roles.
    function grantRoles(
        address[] calldata entities,
        bytes32[] calldata roles
    ) external;

    /// @notice Grants role to an entity.
    /// @param who An entity address.
    /// @param role A role (OZ AccessControl like).
    function grantRole(address who, bytes32 role) external;

    /// @notice Grants role to an entity.
    /// @param who An entity address.
    /// @param role A role (OZ AccessControl like).
    function revokeRole(address who, bytes32 role) external;

    /// @notice Checks if an entity has a role.
    /// @param who An entity address.
    /// @param role A role (OZ AccessControl like).
    function hasRole(address who, bytes32 role) external view returns (bool);
}
