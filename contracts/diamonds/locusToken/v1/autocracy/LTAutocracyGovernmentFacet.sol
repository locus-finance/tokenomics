// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "../../../facetsFramework/diamondBase/facets/BaseFacet.sol";
import "./libraries/AutocracyGovernmentLib.sol";
import "./libraries/AutocracyLib.sol";
import "./interfaces/ILTAutocracyGovernmentFacet.sol";
import "./interfaces/ILTAutocracyFacet.sol";

/// @title This facet manages the permissions and delegation for autocratic governance in the system.
/// @author Oleg Bedrin <o.bedrin@locus.finance> - Locus Team
/// @notice The contract is meant to be utilized as a EIP2535 proxy facet. Hence it cannot be called directly and not through
/// the diamond proxy.
contract LTAutocracyGovernmentFacet is BaseFacet, ILTAutocracyGovernmentFacet {
    /// @inheritdoc ILTAutocracyGovernmentFacet
    function enforceAutocracyGovernmentDelegatee(address who, bytes4 selector) external view override internalOnly {
        if (RolesManagementLib.hasRole(who, AutocracyLib.AUTOCRAT_ROLE)) {
            return;
        }
        if (!AutocracyGovernmentLib.get().entityToSelectorToAllowedToCall[who][selector]) {
            revert IsNotAllowedByTheAutocract(selector, who);
        }
    }

    /// @notice Internal function to set the status of permission for an address to call a specific function.
    /// @dev Can only be called by an address with the `AUTOCRAT_ROLE`.
    /// @param who The address whose permissions are being set.
    /// @param selector The function selector being granted or revoked.
    /// @param status A boolean indicating whether the address is allowed to call the function.
    function _setStatusOfSelectorUsageTo(address who, bytes4 selector, bool status) internal {
        RolesManagementLib.enforceSenderRole(AutocracyLib.AUTOCRAT_ROLE);
        AutocracyGovernmentLib.get().entityToSelectorToAllowedToCall[who][selector] = status;
        emit SelectorUsageStatusSet(who, selector, status);
    }

    /// @inheritdoc ILTAutocracyGovernmentFacet
    function setStatusOfSelectorUsageTo(address who, bytes4 selector, bool status) external override delegatedOnly {
        _setStatusOfSelectorUsageTo(who, selector, status);
    }

    /// @inheritdoc ILTAutocracyGovernmentFacet
    function setStatusOfMintingBurningSelectorsFor(address who, bool status) external override delegatedOnly {
        _setStatusOfSelectorUsageTo(who, ILTAutocracyFacet.mint.selector, status);
        _setStatusOfSelectorUsageTo(who, ILTAutocracyFacet.burn.selector, status);
    }
}
