// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

import "../facetsFramework/diamondBase/interfaces/IRolesManagement.sol";

import "./v1/interfaces/ILTInitializerFacet.sol";


/// @notice IMPORTANT: all of the collective diamond interfaces MUST be prefixed with "Diamond" word.
/// @dev This MUST aggregate all of the faucets interfaces, to be able to grasp a full view of ABI in one place.
interface DiamondAutoreflectiveStaking is 
    IRolesManagement,
    ILTInitializerFacet,
    IERC20Metadata
{}