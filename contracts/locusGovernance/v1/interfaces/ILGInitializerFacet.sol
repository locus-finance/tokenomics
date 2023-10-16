// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

interface ILGInitializerFacet {
    function initialize(
        address locus,
        uint48 initialVotingDelay,
        uint32 initialVotingPeriod, 
        uint256 initialProposalThresholdInLocusTokens,
        uint256 quorumFractionInPercents
    ) external;
}
