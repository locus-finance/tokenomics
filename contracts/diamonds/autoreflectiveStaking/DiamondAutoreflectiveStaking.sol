// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

import "../facetsFramework/diamondBase/interfaces/IRolesManagement.sol";

import "./v1/interfaces/IASInitializerFacet.sol";
import "./v1/interfaces/IASDepositaryFacet.sol";
import "./v1/interfaces/IASEip20Facet.sol";
import "./v1/interfaces/IASReflectionFacet.sol";
import "./v1/interfaces/IASReflectionLoupeFacet.sol";
import "./v1/interfaces/IASFeeAdvisorFacet.sol";

/// @notice IMPORTANT: all of the collective diamond interfaces MUST be prefixed with "Diamond" word.
/// @dev This MUST aggregate all of the faucets interfaces, to be able to grasp a full view of ABI in one place.
interface DiamondAutoreflectiveStaking is 
    IRolesManagement,
    IASInitializerFacet,
    IASDepositaryFacet,
    IASEip20Facet,
    IASReflectionFacet,
    IASReflectionLoupeFacet,
    IASFeeAdvisorFacet
{}
