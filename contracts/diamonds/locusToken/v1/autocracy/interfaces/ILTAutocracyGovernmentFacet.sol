// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

/// @title This facet manages the permissions and delegation for autocratic governance in the system.
/// @author Oleg Bedrin <o.bedrin@locus.finance> - Locus Team
/// @notice The contract is meant to be utilized as a EIP2535 proxy facet. Hence it cannot be called directly and not through
/// the diamond proxy.
interface ILTAutocracyGovernmentFacet {
    event SelectorUsageStatusSet(
        address indexed entity,
        bytes4 indexed selector,
        bool indexed status
    );
    error IsNotAllowedByTheAutocract(bytes4 selector, address whoCalled);

    /// @notice Enforces that a delegatee is allowed to call a specific function under autocratic governance.
    /// @dev Only callable internally (within one diamond). It checks if the caller has the `AUTOCRAT_ROLE` or if the function call is explicitly allowed.
    /// @param who The address attempting to call the function.
    /// @param selector The function selector being called.
    function enforceAutocracyGovernmentDelegatee(
        address who,
        bytes4 selector
    ) external view;


    /// @notice Internal function to set the status of permission for an address to call a specific function.
    /// @dev Can only be called by an address with the `AUTOCRAT_ROLE`.
    /// @param who The address whose permissions are being set.
    /// @param selector The function selector being granted or revoked.
    /// @param status A boolean indicating whether the address is allowed to call the function.
    function setStatusOfSelectorUsageTo(
        address who,
        bytes4 selector,
        bool status
    ) external;

    /// @notice Sets the status of an address's permission to call minting and burning functions.
    /// @dev Can only be called by a DELEGATECALL. It sets permissions for both mint and burn selectors.
    /// @param who The address whose permissions are being set.
    /// @param status A boolean indicating whether the address is allowed to call the mint and burn functions.
    function setStatusOfMintingBurningSelectorsFor(
        address who,
        bool status
    ) external;
}
