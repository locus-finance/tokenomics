// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import "./interfaces/ILSProcessFeesFacet.sol";
import "../../LSLib.sol";
import "../../../diamondBase/facets/BaseFacet.sol";
import "./libraries/LSFeesLib.sol";

contract LSProcessFeesFacet is BaseFacet, ILSProcessFeesFacet {
    using SafeERC20 for IERC20;

    function getFeesAccountedRewardAndDistributeFees(
        uint256 reward,
        IERC20 rewardsToken
    ) external override internalOnly returns (uint256 feesSubstractedReward) {
        uint256 feeBps = LSFeesLib.getFee(msg.sender);
        if (feeBps == 0) {
            return reward;
        }
        uint256 feeAmountGathered = (reward * feeBps) / LSFeesLib.MAX_BPS;
        feesSubstractedReward = reward - feeAmountGathered;

        uint256 remainToBeDistributed = feeAmountGathered;
        uint256 sumOfShares = LSFeesLib.get().sumOfShares;
        uint256 feeReceiversLength = LSFeesLib.get().feeReceivers.length;

        for (uint256 i; i < feeReceiversLength; i++) {
            LSFeesLib.FeeReceiver storage containedFeeReceiver = LSFeesLib
                .get()
                .feeReceivers[i];
            if (!containedFeeReceiver.isBlocked) {
                uint256 share = (feeAmountGathered *
                    containedFeeReceiver.share) / sumOfShares;
                rewardsToken.safeTransfer(containedFeeReceiver.receiver, share);
                remainToBeDistributed -= share;
            }
        }
        if (feeAmountGathered > 0) {
            rewardsToken.safeTransfer(LSFeesLib.get().undistributedFeesReceiver, feeAmountGathered);
        }
        emit LSFeesLib.FeesDistributed(feeAmountGathered, remainToBeDistributed);
    }
}
