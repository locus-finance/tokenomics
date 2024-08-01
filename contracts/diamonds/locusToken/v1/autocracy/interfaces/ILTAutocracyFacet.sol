// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

/// @title This facet implements the autocracy facet for a diamond-based architecture. 
/// It includes functions to enable and disable autocracy, and to mint and burn tokens.
/// @author Oleg Bedrin <o.bedrin@locus.finance> - Locus Team
/// @notice The contract is meant to be utilized as a EIP2535 proxy facet. Hence it cannot be called directly and not through
/// the diamond proxy.
interface ILTAutocracyFacet {
    /// @notice Enables autocracy in the system.
    /// @dev Can only be called internally.
    function establishAutocracy() external;

    /// @notice Disables autocracy permanently and removes related functions.
    /// @dev Can only be called by an address with the `REVOLUTIONARY_ROLE`.
    function defeatAutocracyForever() external;

    /// @notice Burns a specified amount of tokens from a given address.
    /// @dev Can only be called by a delegatee authorized by the autocracy government.
    /// @param from The address from which tokens will be burned.
    /// @param amount The amount of tokens to burn.
    function burn(address from, uint256 amount) external;

    /// @notice Mints a specified amount of tokens to a given address.
    /// @dev Can only be called by a delegatee authorized by the autocracy government.
    /// @param who The address to receive the newly minted tokens.
    /// @param amount The amount of tokens to mint.
    function mint(address who, uint256 amount) external;

    /// @notice Checks if the autocrats are currently reigning.
    /// @return A boolean indicating whether autocracy is enabled.
    function areAutocratsReign() external view returns (bool);
}
