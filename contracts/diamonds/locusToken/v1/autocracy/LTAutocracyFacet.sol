// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "hardhat-deploy/solc_0.8/diamond/libraries/LibDiamond.sol";

import "../../../facetsFramework/diamondBase/facets/BaseFacet.sol";
import "./libraries/AutocracyLib.sol";
import "../interfaces/ILTERC20Facet.sol";
import "./interfaces/ILTAutocracyFacet.sol";
import "./interfaces/ILTAutocracyGovernmentFacet.sol";

/// @title This facet implements the autocracy facet for a diamond-based architecture. 
/// It includes functions to enable and disable autocracy, and to mint and burn tokens.
/// @author Oleg Bedrin <o.bedrin@locus.finance> - Locus Team
/// @notice The contract is meant to be utilized as a EIP2535 proxy facet. Hence it cannot be called directly and not through
/// the diamond proxy.
contract LTAutocracyFacet is BaseFacet, ILTAutocracyFacet {
    using LibDiamond for LibDiamond.DiamondStorage;

    /// @inheritdoc ILTAutocracyFacet
    function burn(address from, uint256 amount) external override delegatedOnly {
        ILTAutocracyGovernmentFacet(address(this)).enforceAutocracyGovernmentDelegatee(msg.sender, this.burn.selector);
        ILTERC20Facet(address(this)).burnFrom(from, amount);
    }

    /// @inheritdoc ILTAutocracyFacet
    function mint(address who, uint256 amount) external override delegatedOnly {
        ILTAutocracyGovernmentFacet(address(this)).enforceAutocracyGovernmentDelegatee(msg.sender, this.mint.selector);
        ILTERC20Facet(address(this)).mintTo(who, amount);
    }

    /// @inheritdoc ILTAutocracyFacet
    function establishAutocracy() external override internalOnly {
        AutocracyLib.get().isAutocracyEnabled = true;
    }

    /// @inheritdoc ILTAutocracyFacet
    function areAutocratsReign() external view override delegatedOnly returns (bool) {
        return AutocracyLib.get().isAutocracyEnabled;
    }

    /// @inheritdoc ILTAutocracyFacet
    function defeatAutocracyForever() external override delegatedOnly {
        RolesManagementLib.enforceSenderRole(AutocracyLib.REVOLUTIONARY_ROLE);
        AutocracyLib.get().isAutocracyEnabled = false;
        LibDiamond.diamondStorage().removeFunction(__self, this.defeatAutocracyForever.selector);
        LibDiamond.diamondStorage().removeFunction(__self, this.establishAutocracy.selector);
        LibDiamond.diamondStorage().removeFunction(__self, this.mint.selector);
        LibDiamond.diamondStorage().removeFunction(__self, this.burn.selector);
    }
}
