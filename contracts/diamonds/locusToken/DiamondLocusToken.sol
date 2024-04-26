// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Permit.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

import "../facetsFramework/diamondBase/interfaces/IRolesManagement.sol";

import "../facetsFramework/tokensDistributor/v1/interfaces/ITDLoupeFacet.sol";
import "../facetsFramework/tokensDistributor/v1/interfaces/ITDManagementFacet.sol";
import "../facetsFramework/tokensDistributor/v1/interfaces/ITDProcessFacet.sol";

import "./v1/interfaces/ILTERC20Facet.sol";
import "./v1/interfaces/ILTEmissionControlFacet.sol";
import "./v1/interfaces/ILTInitializerFacet.sol";

import "./v1/autocracy/interfaces/ILTAutocracyFacet.sol";
import "./v1/autocracy/interfaces/ILTAutocracyGovernmentFacet.sol";

/// @notice IMPORTANT: all of the collective diamond interfaces MUST be prefixed with "Diamond" word.
/// @dev This MUST aggregate all of the faucets interfaces, to be able to grasp a full view of ABI in one place.
interface DiamondLocusToken is 
    IRolesManagement,
    ITDLoupeFacet,
    ITDManagementFacet,
    ITDProcessFacet,
    ILTERC20Facet,
    IERC20Permit,
    IERC20Metadata,
    ILTEmissionControlFacet,
    ILTInitializerFacet,
    ILTAutocracyFacet,
    ILTAutocracyGovernmentFacet
{}
