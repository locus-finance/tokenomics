// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;


interface ILGGovernorFacet {
    function _initialize_LGGovernorFacet(
        address locus,
        uint48 initialVotingDelay,
        uint32 initialVotingPeriod, 
        uint256 initialProposalThresholdInLocusTokens,
        uint256 quorumFractionInPercents,
        string memory governorName
    ) external;
}
