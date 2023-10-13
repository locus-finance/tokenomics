// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "./feesManagement/libraries/LSFeesLib.sol";
import "../LSLib.sol";
import "../../diamondBase/facets/BaseFacet.sol";
import "./interfaces/ILSInitializerFacet.sol";
import "./interfaces/ILSDepositaryFacet.sol";

contract LSInitializerFacet is BaseFacet, ILSInitializerFacet {
    function initialize(
        address owner,
        address votingEscrow,
        address rewardDistributor,
        address rewardsToken,
        address stakingToken,
        uint32[] memory feeDurationPoints,
        uint16[] memory feeBasePoints
    ) external override delegatedOnly {
        InitializerLib.initialize();
        ILSDepositaryFacet(address(this))._initialize_LSDepositaryFacet();

        if (feeDurationPoints.length != feeBasePoints.length) {
            revert LSFeesLib.IncorrectLengths(feeDurationPoints.length, feeDurationPoints.length);
        }

        LSFeesLib.Storage storage s = LSFeesLib.get();
        uint32 maxFeePoint; 
        for (uint256 i = 0; i < feeDurationPoints.length; i++) {
            if (feeBasePoints[i] > LSFeesLib.MAX_BPS) {
                revert LSFeesLib.InvalidBPS(feeBasePoints[i]);
            } else {
                s.feeDurationPointIdxToFeeBasePoints[i] = feeBasePoints[i];
            }
            if (feeDurationPoints[i] > maxFeePoint) {
                maxFeePoint = feeDurationPoints[i];
            } else {
                revert LSFeesLib.IntervalsMustBeSorted();
            }
        }
        s.feeDurationPoints = feeDurationPoints;
        s.undistributedFeesReceiver = owner;

        RolesManagementLib.grantRole(rewardDistributor, LSLib.REWARD_DISTRIBUTOR_ROLE);
        RolesManagementLib.grantRole(owner, RolesManagementLib.OWNER_ROLE);
        
        LSLib.Primitives storage p = LSLib.get().p;
        p.rewardsToken = IERC20(rewardsToken);
        p.stakingToken = IERC20(stakingToken);
        p.votingEscrow = votingEscrow;
        p.rewardsDuration = 4 weeks;
    }
}