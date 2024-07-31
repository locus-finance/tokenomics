// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

import "./interfaces/ITDManagementFacet.sol";
import "../../diamondBase/facets/BaseFacet.sol";
import "../TDLib.sol";

/// @title A facet which is a part of `tokenDistributor` group of facets. It allows to add new receivers of tokens and manipulate
/// their status (whether they're blocked which means they're excluded from the distribution) and their shares in a distribution.
/// @author Oleg Bedrin <o.bedrin@locus.finance> - Locus Team
/// @notice The contract is meant to be utilized as a EIP2535 proxy facet. Hence it cannot be called directly and not through
/// the diamond proxy.
contract TDManagementFacet is BaseFacet, ITDManagementFacet {
    using EnumerableSet for EnumerableSet.UintSet;

    /// @inheritdoc ITDManagementFacet
    function addReceiver(
        address distributionReceiver,
        uint256 share,
        bool status
    ) external override delegatedOnly {
        _enforceSenderOwnerOrInternal();
        TDLib.get().distributionReceivers.push(
            TDLib.DistributionReceiver({
                previousShare: 0,
                share: share,
                receiver: distributionReceiver,
                isBlocked: status
            })
        );
        TDLib.get().sumOfShares += share;
        emit TDLib.ReceiverAltered(
            distributionReceiver,
            share,
            status,
            TDLib.get().sumOfShares
        );
    }

    /// @inheritdoc ITDManagementFacet
    function setReceiverShare(
        address distributionReceiver,
        uint256 share
    ) external override delegatedOnly {
        _enforceSenderOwnerOrInternal();
        uint256 len = TDLib.get().distributionReceivers.length;
        for (uint256 i = 0; i < len; i++) {
            TDLib.DistributionReceiver storage containedReceiver = TDLib
                .get()
                .distributionReceivers[i];
            if (containedReceiver.receiver == distributionReceiver) {
                uint256 containedReceiverShare = containedReceiver.share;
                if (containedReceiverShare != share) {
                    if (containedReceiverShare > share) {
                        TDLib.get().sumOfShares -=
                            containedReceiverShare -
                            share;
                    } else {
                        TDLib.get().sumOfShares +=
                            share -
                            containedReceiverShare;
                    }
                    containedReceiver.share = share;
                }
                emit TDLib.ReceiverAltered(
                    distributionReceiver,
                    share,
                    containedReceiver.isBlocked,
                    TDLib.get().sumOfShares
                );
                return;
            }
        }
    }

    /// @inheritdoc ITDManagementFacet
    function setReceiverStatus(
        address distributionReceiver,
        bool status
    ) external override delegatedOnly {
        _enforceSenderOwnerOrInternal();
        uint256 len = TDLib.get().distributionReceivers.length;
        for (uint256 i = 0; i < len; i++) {
            TDLib.DistributionReceiver storage containedReceiver = TDLib
                .get()
                .distributionReceivers[i];
            if (containedReceiver.receiver == distributionReceiver) {
                if (containedReceiver.isBlocked != status) {
                    containedReceiver.isBlocked = status;
                    if (status) {
                        uint256 previousShare = containedReceiver.share;
                        containedReceiver.previousShare = previousShare;
                        containedReceiver.share = 0;
                        TDLib.get().sumOfShares -= previousShare;
                    } else {
                        uint256 _share = containedReceiver.previousShare;
                        containedReceiver.previousShare = 0;
                        containedReceiver.share = _share;
                        TDLib.get().sumOfShares += _share;
                    }
                }
                emit TDLib.ReceiverAltered(
                    distributionReceiver,
                    containedReceiver.share,
                    status,
                    TDLib.get().sumOfShares
                );
                return;
            }
        }
    }

    /// @dev Just a wrapper function to check if sender is either diamond itself or `OWNER_ROLE` bearer.
    function _enforceSenderOwnerOrInternal() internal view {
        bytes32[] memory roles = new bytes32[](2);
        roles[0] = RolesManagementLib.OWNER_ROLE;
        roles[1] = RolesManagementLib.INTERNAL_ROLE;
        RolesManagementLib.enforceSenderEitherOfRoles(roles);
    }
}
