// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import "../diamondBase/interfaces/IRolesManagement.sol";

/// @notice IMPORTANT: all of the collective diamond interfaces MUST be prefixed with "Diamond" word.
/// @dev This MUST aggregate all of the faucets interfaces, to be able to grasp a full view of ABI in one place.
interface DiamondLocusGauge is IRolesManagement {}
