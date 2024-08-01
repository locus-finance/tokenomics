// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/governance/utils/IVotes.sol";
import "@openzeppelin/contracts/governance/Governor.sol";
import "@openzeppelin/contracts/governance/extensions/GovernorSettings.sol";
import "@openzeppelin/contracts/governance/extensions/GovernorCountingSimple.sol";
import "@openzeppelin/contracts/governance/extensions/GovernorVotes.sol";
import "@openzeppelin/contracts/governance/extensions/GovernorVotesQuorumFraction.sol";

/// @notice Classic OZ Governor without any custom functionality.
contract LocusGovernor is
    Governor,
    GovernorSettings,
    GovernorCountingSimple,
    GovernorVotes,
    GovernorVotesQuorumFraction
{

    constructor(
        address wrappedStakingLocus,
        uint48 initialVotingDelay,
        uint32 initialVotingPeriod,
        uint256 initialProposalThresholdInLocusTokens,
        uint256 quorumFractionInPercents,
        string memory governorName
    ) 
        Governor(governorName)
        GovernorSettings(
            initialVotingDelay, 
            initialVotingPeriod, 
            initialProposalThresholdInLocusTokens
        )
        GovernorVotes(IVotes(wrappedStakingLocus))
        GovernorVotesQuorumFraction(quorumFractionInPercents)
    {}

    function proposalThreshold()
        public
        view
        override(Governor, GovernorSettings)
        returns (uint256)
    {
        return super.proposalThreshold();
    }
}
