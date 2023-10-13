//SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "./interfaces/ILSFeesManagementLoupeFacet.sol";
import "./libraries/LSFeesLib.sol";
import "../../../diamondBase/facets/BaseFacet.sol";

contract LSFeesManagementLoupeFacet is BaseFacet, ILSFeesManagementLoupeFacet {
    function getFeeReceiversByAddresses(
        uint256 offset,
        uint256 windowSize,
        address[] memory addresses
    ) external view override delegatedOnly returns (uint256[] memory indicies) {
        uint256 feeReceiversLength = LSFeesLib.get().feeReceivers.length;
        if (offset >= feeReceiversLength) {
            revert LSFeesLib.InvalidOffset(offset);
        }
        indicies = new uint256[](windowSize);
        uint256 coursor;
        bool foundAny;
        for (uint256 i = offset; i < feeReceiversLength; i++) {
            for (uint256 j = 0; j < addresses.length; j++) {
                if (LSFeesLib.get().feeReceivers[i].receiver == addresses[j]) {
                    indicies[coursor++] = i;
                    if (!foundAny) foundAny = true;
                }
            }
        }
        if (!foundAny) {
            revert LSFeesLib.NothingWasFound();
        }
    }

    function getFeeReceiversByShares(
        uint256 offset,
        uint256 windowSize,
        uint256[] memory shares
    ) external view override delegatedOnly returns (uint256[] memory indicies) {
        uint256 feeReceiversLength = LSFeesLib.get().feeReceivers.length;
        if (offset >= feeReceiversLength) {
            revert LSFeesLib.InvalidOffset(offset);
        }
        indicies = new uint256[](windowSize);
        uint256 coursor;
        bool foundAny;
        for (uint256 i = offset; i < feeReceiversLength; i++) {
            for (uint256 j = 0; j < shares.length; j++) {
                if (LSFeesLib.get().feeReceivers[i].share == shares[j]) {
                    indicies[coursor++] = i;
                    if (!foundAny) foundAny = true;
                }
            }
        }
        if (!foundAny) {
            revert LSFeesLib.NothingWasFound();
        }
    }

    function getFeeReceiversByStatuses(
        uint256 offset,
        uint256 windowSize,
        bool[] memory statuses
    ) external view override delegatedOnly returns (uint256[] memory indicies) {
        uint256 feeReceiversLength = LSFeesLib.get().feeReceivers.length;
        if (offset >= feeReceiversLength) {
            revert LSFeesLib.InvalidOffset(offset);
        }
        indicies = new uint256[](windowSize);
        uint256 coursor;
        bool foundAny;
        for (uint256 i = offset; i < feeReceiversLength; i++) {
            for (uint256 j = 0; j < statuses.length; j++) {
                if (LSFeesLib.get().feeReceivers[i].isBlocked == statuses[j]) {
                    indicies[coursor++] = i;
                    if (!foundAny) foundAny = true;
                }
            }
        }
        if (!foundAny) {
            revert LSFeesLib.NothingWasFound();
        }
    }

    function getFeeReceiverByIdx(
        uint256 idx
    ) external view delegatedOnly returns (LSFeesLib.FeeReceiver memory) {
        if (idx >= LSFeesLib.get().feeReceivers.length) {
            revert LSFeesLib.InvalidOffset(idx);
        }
        return LSFeesLib.get().feeReceivers[idx];
    }

    function getSumOfShares()
        external
        view
        override
        delegatedOnly
        returns (uint256)
    {
        return LSFeesLib.get().sumOfShares;
    }
}
