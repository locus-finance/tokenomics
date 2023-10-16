// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "./interfaces/ILTInitializerFacet.sol";
import "../LTLib.sol";
import "../../diamondBase/facets/BaseFacet.sol";
import "../../tokensDistributor/TDLib.sol";
import "../../tokensDistributor/v1/interfaces/ITDManagementFacet.sol";

import "./autocracy/interfaces/ILTAutocracyFacet.sol";
import "./autocracy/libraries/AutocracyLib.sol";

contract LTInitializerFacet is BaseFacet, ILTInitializerFacet {
    function initialize(
        address undistributedAmountsReceiver,
        address[] calldata distributionReceivers,
        uint32[] calldata distributionDurationPoints,
        uint256[][] calldata amountsPerEpoch
    ) external override {
        InitializerLib.initialize();

        if (distributionReceivers.length == 0) {
            revert TDLib.IncorrectLengths(distributionReceivers.length, 0);
        }
        if (amountsPerEpoch.length != distributionReceivers.length) {
            revert TDLib.IncorrectLengths(amountsPerEpoch.length, distributionReceivers.length);
        }
        if (distributionDurationPoints.length != amountsPerEpoch[0].length) {
            revert TDLib.IncorrectLengths(distributionDurationPoints.length, amountsPerEpoch[0].length);
        }
        
        TDLib.Storage storage s = TDLib.get();
        uint32 maxDistributionPoint;
        
        for (uint256 i = 0; i < distributionDurationPoints.length; i++) {
            if (distributionDurationPoints[i] > maxDistributionPoint) {
                maxDistributionPoint = distributionDurationPoints[i];
            } else {
                revert TDLib.IntervalsMustBeSorted();
            }
            
            // Greedily initialize the storage.
            for (uint256 j = 0; j < distributionReceivers.length; j++) {
                s.startTimestamps[distributionReceivers[j]] = uint32(block.timestamp);
                s.distributionDurationPointIdxToMiddlemanToAmounts[i][distributionReceivers[j]] = 
                    amountsPerEpoch[j][i];
                ITDManagementFacet(address(this)).addReceiver(
                    distributionReceivers[j],
                    50,
                    true
                );
            }
        }
        
        s.distributionDurationPoints = distributionDurationPoints;
        s.undistributedAmountsReceiver = undistributedAmountsReceiver;

        RolesManagementLib.grantRole(undistributedAmountsReceiver, AutocracyLib.REVOLUTIONARY_ROLE);
        RolesManagementLib.grantRole(undistributedAmountsReceiver, AutocracyLib.AUTOCRAT_ROLE);
        ILTAutocracyFacet(address(this)).establishAutocracy();
    }
}