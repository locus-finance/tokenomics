// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

// look for the Diamond.sol in the hardhat-deploy/solc_0.8/Diamond.sol
library RolesManagementLib {
    /// @notice Emits when a relation between enitity and role change.
    /// @param who An entity.
    /// @param role A role.
    /// @param isGrantedOrRevoked True - role is granted. False - role is revoked. 
    event RoleSet(address who, bytes32 role, bool isGrantedOrRevoked);

    error HasNoRole(address who, bytes32 role);
    error HasNoRoles(address who, bytes32[] roles);

    /// @dev Slot number when the storage has been markdowned.
    bytes32 constant ROLES_MANAGEMENT_STORAGE_POSITION = keccak256("diamond.standard.diamond.storage.locus.roles");

    /// @dev Roles to check with EOA
    bytes32 public constant PAUSER_ROLE = keccak256('PAUSER_ROLE');
    bytes32 public constant OWNER_ROLE = keccak256('OWNER_ROLE');

    /// @dev A special role - must not be removed.
    bytes32 public constant INTERNAL_ROLE = keccak256('INTERNAL_ROLE');

    /// @dev Roles to check with smart-contracts
    bytes32 public constant ALLOWED_TOKEN_ROLE = keccak256('ALLOWED_TOKEN_ROLE');

    /// @dev Main storage markdown
    struct Storage {
        mapping(bytes32 => mapping(address => bool)) roles;
    }

    /// @dev Returns the storage part that manipulable through Storage struct operations.
    function get() internal pure returns (Storage storage s) {
        bytes32 position = ROLES_MANAGEMENT_STORAGE_POSITION;
        assembly {
            s.slot := position
        }
    }

    /// @dev Forces `who` to bear `role`. If not - reverts. 
    /// But if the `who` is the diamonds facet, forces it to belong to the diamond.
    /// @param who An entity.
    /// @param role A role.
    function enforceRole(address who, bytes32 role) internal view {
        if (role == INTERNAL_ROLE) {
            if (who != address(this)) {
                revert HasNoRole(who, INTERNAL_ROLE);
            }
        } else if (!get().roles[role][who]) {
            revert HasNoRole(who, role);
        }
        
    }

    /// @dev Checks if an entity has a role.
    /// @param who An entity.
    /// @param role A role.
    function hasRole(address who, bytes32 role) internal view returns(bool) {
        return get().roles[role][who];
    }

    /// @dev Forces sender of the DELEGATECALL to bear a role.
    /// @param role A role.
    function enforceSenderRole(bytes32 role) internal view {
        enforceRole(msg.sender, role);
    }

    /// @dev Grants role to an entity.
    /// @param who An entity.
    /// @param role A role.
    function grantRole(address who, bytes32 role) internal {
        get().roles[role][who] = true; 
        emit RoleSet(who, role, true);
    }

    /// @dev Revokes role from an entity.
    /// @param who An entity.
    /// @param role A role.
    function revokeRole(address who, bytes32 role) internal {
        get().roles[role][who] = false; 
        emit RoleSet(who, role, false);
    }

    /// @dev Forces an entity to bear a role.
    /// @param who An entity.
    /// @param roles A group of roles for the entity to bear.
    function enforceEitherOfRoles(address who, bytes32[] memory roles) internal view {
        bool result;
        for (uint256 i = 0; i < roles.length; i++) {
            if (roles[i] == INTERNAL_ROLE) {
                result = result || who == address(this);
            } else {
                result = result || get().roles[roles[i]][who];
            }
        }
        if (!result) {
            revert HasNoRoles(who, roles);
        }
    }

    /// @dev Forces sender of the DELEGATECALL to bear roles.
    /// @param roles A group of roles to bear.
    function enforceSenderEitherOfRoles(bytes32[] memory roles) internal view {
        enforceEitherOfRoles(msg.sender, roles);
    }
}