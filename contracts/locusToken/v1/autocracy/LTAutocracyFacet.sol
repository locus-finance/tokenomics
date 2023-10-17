// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "hardhat-deploy/solc_0.8/diamond/libraries/LibDiamond.sol";

import "../../../diamondBase/facets/BaseFacet.sol";
import "./libraries/AutocracyLib.sol";
import "../interfaces/ILTERC20Facet.sol";
import "./interfaces/ILTAutocracyFacet.sol";

contract LTAutocracyFacet is BaseFacet, ILTAutocracyFacet {
    using LibDiamond for LibDiamond.DiamondStorage;

    function burn(uint256 amount) external override delegatedOnly {
        RolesManagementLib.enforceSenderRole(AutocracyLib.AUTOCRAT_ROLE);
        ILTERC20Facet(address(this)).burnFrom(msg.sender, amount);
    }

    function mint(address who, uint256 amount) external override delegatedOnly {
        RolesManagementLib.enforceSenderRole(AutocracyLib.AUTOCRAT_ROLE);
        ILTERC20Facet(address(this)).mintTo(who, amount);
    }

    function establishAutocracy() external override internalOnly {
        AutocracyLib.get().isAutocracyEnabled = true;
    }

    function defeatAutocracyForever() external override delegatedOnly {
        RolesManagementLib.enforceSenderRole(AutocracyLib.REVOLUTIONARY_ROLE);
        AutocracyLib.get().isAutocracyEnabled = false;
        LibDiamond.diamondStorage().removeFunction(__self, this.defeatAutocracyForever.selector);
        LibDiamond.diamondStorage().removeFunction(__self, this.establishAutocracy.selector);
    }
}
