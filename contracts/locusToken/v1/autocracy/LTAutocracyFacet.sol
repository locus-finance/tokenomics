// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "hardhat-deploy/solc_0.8/diamond/libraries/LibDiamond.sol";

import "../../../diamondBase/facets/BaseFacet.sol";
import "./libraries/AutocracyLib.sol";

contract LTAutocracyFacet is BaseFacet {
    using LibDiamond for LibDiamond.DiamondStorage;

    function establishAutocracy() external internalOnly {
        AutocracyLib.get().isAutocracyEnabled = true;
    }

    function defeatAutocracyForever() external delegatedOnly {
        RolesManagementLib.enforceSenderRole(AutocracyLib.REVOLUTIONARY_ROLE);
        AutocracyLib.get().isAutocracyEnabled = false;
        LibDiamond.diamondStorage().removeFunction(__self, this.defeatAutocracyForever.selector);
        LibDiamond.diamondStorage().removeFunction(__self, this.establishAutocracy.selector);
    }
}
