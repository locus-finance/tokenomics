// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "./interfaces/ILGInitializerFacet.sol";
import "./interfaces/ILGGovernorFacet.sol";
import "../../facetsFramework/diamondBase/facets/BaseFacet.sol";

contract LGInitializerFacet is BaseFacet, ILGInitializerFacet {
    function initialize(
        address locus,
        uint48 initialVotingDelay,
        uint32 initialVotingPeriod, 
        uint256 initialProposalThresholdInLocusTokens,
        uint256 quorumFractionInPercents
    ) external override initializer {
        InitializerLib.initialize();
        ILGGovernorFacet(address(this))._initialize_LGGovernorFacet(
            locus, 
            initialVotingDelay,
            initialVotingPeriod,
            initialProposalThresholdInLocusTokens,
            quorumFractionInPercents,
            "Locus Governor"
        );
    }
}