// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

import "../LSLib.sol";
import "../../facetsFramework/diamondBase/facets/BaseFacet.sol";
import "../../facetsFramework/tokensDistributor/TDLib.sol";

import "./interfaces/ILSInitializerFacet.sol";
import "./interfaces/ILSDepositaryFacet.sol";

contract LSInitializerFacet is BaseFacet, ILSInitializerFacet {
    function initialize(
        address owner,
        address locusToken,
        address rewardDistributor,
        address rewardsToken,
        address stakingToken,
        uint32[] memory feeDurationPoints,
        uint16[] memory feeBasePoints
    ) external override {
        InitializerLib.initialize();

        _setFeesSettings(owner, feeDurationPoints, feeBasePoints);

        RolesManagementLib.grantRole(
            rewardDistributor,
            LSLib.REWARD_DISTRIBUTOR_ROLE
        );
        RolesManagementLib.grantRole(owner, RolesManagementLib.OWNER_ROLE);

        LSLib.Primitives storage p = LSLib.get().p;
        p.rewardsToken = IERC20Metadata(rewardsToken);
        p.stakingToken = IERC20Metadata(stakingToken);
        p.rewardsDuration = 4 weeks;
        p.locusToken = locusToken;
    }

    function prepareDepositary() external override delegatedOnly {
        RolesManagementLib.enforceSenderRole(RolesManagementLib.OWNER_ROLE);
        // WARNING: CONTAINS INITIALIZER CUSTOM MODIFIER, SO IT COULDN'T BE CALLED TWICE.
        ILSDepositaryFacet(address(this))._initialize_LSDepositaryFacet();
    }

    function setFeesSettings(
        address undistributedAmountsReceiver,
        uint32[] memory feeDurationPoints,
        uint16[] memory feeBasePoints
    ) external override delegatedOnly {
        RolesManagementLib.enforceSenderRole(RolesManagementLib.OWNER_ROLE);
        _setFeesSettings(undistributedAmountsReceiver, feeDurationPoints, feeBasePoints);
    }

    /// @dev DEPRECATED
    function _setFeesSettings(
        address undistributedAmountsReceiver,
        uint32[] memory feeDurationPoints,
        uint16[] memory feeBasePoints
    ) internal {
        if (feeDurationPoints.length != feeBasePoints.length) {
            revert TDLib.IncorrectLengths(
                feeDurationPoints.length,
                feeDurationPoints.length
            );
        }
        TDLib.Storage storage s = TDLib.get();
        uint32 maxFeePoint;
        // just checking bps values and so they are sorted
        for (uint256 i = 0; i < feeDurationPoints.length; i++) {
            if (feeBasePoints[i] > TDLib.MAX_BPS) {
                revert LSLib.InvalidBPS(feeBasePoints[i]);
            } else {
                s.distributionDurationPointIdxToAmounts[i] = feeBasePoints[i];
            }
            if (feeDurationPoints[i] >= maxFeePoint) {
                maxFeePoint = feeDurationPoints[i];
            } else {
                revert TDLib.IntervalsMustBeSorted();
            }
        }
        s.distributionDurationPoints = feeDurationPoints;
        s.undistributedAmountsReceiver = undistributedAmountsReceiver;
    }
}
