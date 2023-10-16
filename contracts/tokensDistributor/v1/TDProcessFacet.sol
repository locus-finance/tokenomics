// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import "./interfaces/ITDProcessFacet.sol";
import "../../diamondBase/facets/BaseFacet.sol";

import "../TDLib.sol";

contract TDProcessFacet is BaseFacet, ITDProcessFacet {
    using SafeERC20 for IERC20;

    function distribute(
        uint256 amount,
        IERC20 token
    ) external override internalOnly {
        uint256 remainToBeDistributed = amount;
        uint256 sumOfShares = TDLib.get().sumOfShares;
        uint256 feeReceiversLength = TDLib.get().distributionReceivers.length;

        for (uint256 i; i < feeReceiversLength; i++) {
            TDLib.DistributionReceiver storage containedFeeReceiver = TDLib
                .get()
                .distributionReceivers[i];
            if (!containedFeeReceiver.isBlocked) {
                uint256 share = (amount * containedFeeReceiver.share) /
                    sumOfShares;
                token.safeTransfer(containedFeeReceiver.receiver, share);
                remainToBeDistributed -= share;
            }
        }
        if (remainToBeDistributed > 0) {
            token.safeTransfer(
                TDLib.get().undistributedAmountsReceiver,
                remainToBeDistributed
            );
        }
        emit TDLib.Distributed(amount, remainToBeDistributed);
    }
}
