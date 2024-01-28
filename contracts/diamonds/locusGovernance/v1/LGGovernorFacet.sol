// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts-upgradeable/governance/utils/IVotesUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/governance/GovernorUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/governance/extensions/GovernorSettingsUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/governance/extensions/GovernorCountingSimpleUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/governance/extensions/GovernorVotesUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/governance/extensions/GovernorVotesQuorumFractionUpgradeable.sol";

import "../../facetsFramework/diamondBase/facets/BaseFacet.sol";
import "./interfaces/ILGGovernorFacet.sol";

contract LGGovernorFacet is
    BaseFacet,
    ILGGovernorFacet,
    GovernorUpgradeable,
    GovernorSettingsUpgradeable,
    GovernorCountingSimpleUpgradeable,
    GovernorVotesUpgradeable,
    GovernorVotesQuorumFractionUpgradeable
{

    function _initialize_LGGovernorFacet(
        address locus,
        uint48 initialVotingDelay,
        uint32 initialVotingPeriod,
        uint256 initialProposalThresholdInLocusTokens,
        uint256 quorumFractionInPercents,
        string memory governorName
    ) external override initializer internalOnly {
        __Governor_init(governorName);
        __GovernorSettings_init(
            initialVotingDelay,
            initialVotingPeriod,
            initialProposalThresholdInLocusTokens
        );
        __GovernorCountingSimple_init();
        __GovernorVotes_init(IVotesUpgradeable(locus));
        __GovernorVotesQuorumFraction_init(quorumFractionInPercents);
    }

    function proposalThreshold()
        public
        view
        override(GovernorUpgradeable, GovernorSettingsUpgradeable)
        returns (uint256)
    {
        return super.proposalThreshold();
    }
}
