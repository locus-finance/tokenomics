//SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

import "./interfaces/ILSFeesManagementFacet.sol";
import "../../../diamondBase/facets/BaseFacet.sol";
import "./libraries/LSFeesLib.sol";

contract LSFeesManagementFacet is BaseFacet, ILSFeesManagementFacet {
    using EnumerableSet for EnumerableSet.UintSet;

    function addFeeReceiver(
        address feeReceiver,
        uint256 share,
        bool status
    ) external override delegatedOnly {
        RolesManagementLib.enforceSenderRole(RolesManagementLib.OWNER_ROLE);
        LSFeesLib.get().feeReceivers.push(
            LSFeesLib.FeeReceiver({
                previousShare: 0,
                share: share,
                receiver: feeReceiver,
                isBlocked: status
            })
        );
        LSFeesLib.get().sumOfShares += share;
        emit LSFeesLib.FeeReceiverAltered(
            feeReceiver,
            share,
            status,
            LSFeesLib.get().sumOfShares
        );
    }

    function setFeeReceiverShare(
        address feeReceiver,
        uint256 share
    ) external override delegatedOnly {
        RolesManagementLib.enforceSenderRole(RolesManagementLib.OWNER_ROLE);
        for (uint256 i = 0; i < LSFeesLib.get().feeReceivers.length; i++) {
            LSFeesLib.FeeReceiver storage containedFeeReceiver = LSFeesLib
                .get()
                .feeReceivers[i];
            if (containedFeeReceiver.receiver == feeReceiver) {
                uint256 containedFeeReceiverShare = containedFeeReceiver.share;
                if (containedFeeReceiverShare != share) {
                    if (containedFeeReceiverShare > share) {
                        LSFeesLib.get().sumOfShares -=
                            containedFeeReceiverShare -
                            share;
                    } else {
                        LSFeesLib.get().sumOfShares +=
                            share -
                            containedFeeReceiverShare;
                    }
                    containedFeeReceiver.share = share;
                }
                emit LSFeesLib.FeeReceiverAltered(
                    feeReceiver,
                    share,
                    containedFeeReceiver.isBlocked,
                    LSFeesLib.get().sumOfShares
                );
                return;
            }
        }
    }

    function setFeeReceiverStatus(
        address feeReceiver,
        bool status
    ) external override delegatedOnly {
        RolesManagementLib.enforceSenderRole(RolesManagementLib.OWNER_ROLE);
        for (uint256 i = 0; i < LSFeesLib.get().feeReceivers.length; i++) {
            LSFeesLib.FeeReceiver storage containedFeeReceiver = LSFeesLib
                .get()
                .feeReceivers[i];
            if (containedFeeReceiver.receiver == feeReceiver) {
                if (containedFeeReceiver.isBlocked != status) {
                    containedFeeReceiver.isBlocked = status;
                    if (status) {
                        uint256 previousShare = containedFeeReceiver.share;
                        containedFeeReceiver.previousShare = previousShare;
                        containedFeeReceiver.share = 0;
                        LSFeesLib.get().sumOfShares -= previousShare;
                    } else {
                        uint256 _share = containedFeeReceiver.previousShare;
                        containedFeeReceiver.previousShare = 0;
                        containedFeeReceiver.share = _share;
                        LSFeesLib.get().sumOfShares += _share;
                    }
                }
                emit LSFeesLib.FeeReceiverAltered(
                    feeReceiver,
                    containedFeeReceiver.share,
                    status,
                    LSFeesLib.get().sumOfShares
                );
                return;
            }
        }
    }
}
