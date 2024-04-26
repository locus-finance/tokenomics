// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "../../../facetsFramework/diamondBase/facets/BaseFacet.sol";
import "./libraries/AutocracyGovernmentLib.sol";
import "./libraries/AutocracyLib.sol";
import "./interfaces/ILTAutocracyGovernmentFacet.sol";
import "./interfaces/ILTAutocracyFacet.sol";

contract LTAutocracyGovernmentFacet is BaseFacet, ILTAutocracyGovernmentFacet {
    function enforceAutocracyGovernmentDelegatee(address who, bytes4 selector) external view override internalOnly {
        if (RolesManagementLib.hasRole(who, AutocracyLib.AUTOCRAT_ROLE)) {
            return;
        }
        if (!AutocracyGovernmentLib.get().entityToSelectorToAllowedToCall[who][selector]) {
            revert IsNotAllowedByTheAutocract(selector, who);
        }
    }

    function _setStatusOfSelectorUsageTo(address who, bytes4 selector, bool status) internal {
        RolesManagementLib.enforceSenderRole(AutocracyLib.AUTOCRAT_ROLE);
        AutocracyGovernmentLib.get().entityToSelectorToAllowedToCall[who][selector] = status;
        emit SelectorUsageStatusSet(who, selector, status);
    }

    function setStatusOfSelectorUsageTo(address who, bytes4 selector, bool status) external override delegatedOnly {
        _setStatusOfSelectorUsageTo(who, selector, status);
    }

    function setStatusOfMintingBurningSelectorsFor(address who, bool status) external override delegatedOnly {
        _setStatusOfSelectorUsageTo(who, ILTAutocracyFacet.mint.selector, status);
        _setStatusOfSelectorUsageTo(who, ILTAutocracyFacet.burn.selector, status);
    }
}
