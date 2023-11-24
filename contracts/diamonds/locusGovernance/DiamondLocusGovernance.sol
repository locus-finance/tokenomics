// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "../facetsFramework/diamondBase/interfaces/IRolesManagement.sol";
import "./v1/interfaces/ILGGovernorFacet.sol";
import "./v1/interfaces/ILGInitializerFacet.sol";

/// @notice IMPORTANT: all of the collective diamond interfaces MUST be prefixed with "Diamond" word.
/// @dev This MUST aggregate all of the faucets interfaces, to be able to grasp a full view of ABI in one place.
interface DiamondLocusGovernance is
    IRolesManagement,
    ILGGovernorFacet,
    ILGInitializerFacet
{}
