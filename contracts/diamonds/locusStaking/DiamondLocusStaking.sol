// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "../facetsFramework/diamondBase/interfaces/IRolesManagement.sol";
import "../facetsFramework/tokensDistributor/v1/interfaces/ITDLoupeFacet.sol";
import "../facetsFramework/tokensDistributor/v1/interfaces/ITDManagementFacet.sol";
import "../facetsFramework/tokensDistributor/v1/interfaces/ITDProcessFacet.sol";

import "./v1/interfaces/ILSDepositaryFacet.sol";
import "./v1/interfaces/ILSInitializerFacet.sol";
import "./v1/interfaces/ILSLoupeFacet.sol";
import "./v1/interfaces/ILSManagementFacet.sol";
import "./v1/interfaces/ILSProcessFeesFacet.sol";

import "./v2/manualWithdrawQueueFacets/interfaces/ILSSendingsDequeFacet.sol";
import "./v2/manualWithdrawQueueFacets/interfaces/ILSSendingsDequeLoupeFacet.sol";

/// @notice IMPORTANT: all of the collective diamond interfaces MUST be prefixed with "Diamond" word.
/// @dev This MUST aggregate all of the faucets interfaces, to be able to grasp a full view of ABI in one place.
interface DiamondLocusStaking is
    IRolesManagement,
    ITDLoupeFacet,
    ITDManagementFacet,
    ITDProcessFacet,
    ILSDepositaryFacet,
    ILSInitializerFacet,
    ILSLoupeFacet,
    ILSManagementFacet,
    ILSProcessFeesFacet,
    ILSSendingsDequeFacet,
    ILSSendingsDequeLoupeFacet
{}
