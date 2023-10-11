// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import "../diamondBase/interfaces/IRolesManagement.sol";
import "./v1/interfaces/IVECheckpointFacet.sol";
import "./v1/interfaces/IVEDepositaryFacet.sol";
import "./v1/interfaces/IVEInitializerFacet.sol";
import "./v1/interfaces/IVELoupeFacet.sol";
import "./v1/interfaces/IVEManagementFacet.sol";

// # Voting escrow to have time-weighted votes
// # Votes have a weight depending on time, so that users are committed
// # to the future of (whatever they are voting for).
// # The weight in this implementation is linear, and lock cannot be more than maxtime:
// # w ^
// # 1 +        /
// #   |      /
// #   |    /
// #   |  /
// #   |/
// # 0 +--------+------> time
// #       maxtime (2 years?)

/// @title Voting Escrow Locus
/// @author Curve Finance | Translation to Solidity and to Diamond Proxy - Locus Team
/// @notice Votes have a weight depending on time, so that users are
/// committed to the future of (whatever they are voting for).
/// IMPORTANT: all of the collective diamond interfaces MUST be prefixed with "Diamond" word.
/// @dev Vote weight decays linearly over time. Lock time cannot be more than `MAXTIME` (2 years).
/// This MUST aggregate all of the faucets interfaces, to be able to grasp a full view of ABI in one place.
interface DiamondVotingEscrow is 
    IRolesManagement,
    IVECheckpointFacet,
    IVEDepositaryFacet,
    IVEInitializerFacet,
    IVELoupeFacet,
    IVEManagementFacet
{}
