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
        address owner,
        address[] calldata distributionReceivers,
        uint256[] calldata distributionReceiversShares,
        uint32[] calldata distributionDurationPoints,
        uint256[][] calldata amountsPerEpochs
    ) external override {
        InitializerLib.initialize();

        if (distributionReceivers.length == 0) {
            revert TDLib.IncorrectLengths(distributionReceivers.length, 0);
        }
        if (distributionReceivers.length != distributionReceiversShares.length) {
            revert TDLib.IncorrectLengths(distributionReceivers.length, distributionReceiversShares.length);
        }
        if (amountsPerEpochs.length != distributionReceivers.length) {
            revert TDLib.IncorrectLengths(amountsPerEpochs.length, distributionReceivers.length);
        }
        if (distributionDurationPoints.length != amountsPerEpochs[0].length) {
            revert TDLib.IncorrectLengths(distributionDurationPoints.length, amountsPerEpochs[0].length);
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
                
                // It has to be equal to a sum of tokens belonging to every distribution receiver per epoch.
                // This maps a duration points (an interval from startTimestamp[...] to a certain point in time represented by the duration of the interval)
                // to an amount that has to be distributed to each epoch.
                s.distributionDurationPointIdxToAmounts[i] = 
                    amountsPerEpochs[j][i];
                
                ITDManagementFacet(address(this)).addReceiver(
                    distributionReceivers[j],
                    distributionReceiversShares[j],
                    true
                );
            }
        }
        
        // Initialize the start of inflation.
        // address(0) is utilized because for every receiver we have one time of inflation start.
        s.startTimestamps[address(0)] = uint32(block.timestamp);
        s.distributionDurationPoints = distributionDurationPoints;
        s.undistributedAmountsReceiver = owner;

        RolesManagementLib.grantRole(owner, RolesManagementLib.OWNER_ROLE);
        RolesManagementLib.grantRole(owner, AutocracyLib.REVOLUTIONARY_ROLE);
        RolesManagementLib.grantRole(owner, AutocracyLib.AUTOCRAT_ROLE);
        ILTAutocracyFacet(address(this)).establishAutocracy();
    }
}