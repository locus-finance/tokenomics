// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "./interfaces/ITDLoupeFacet.sol";
import "../TDLib.sol";
import "../../diamondBase/facets/BaseFacet.sol";

/// @title A facet which is a part of `tokenDistributor` group of facets. It allows to loupe through the data of 
/// receivers of tokens and their shares. 
/// @author Oleg Bedrin <o.bedrin@locus.finance> - Locus Team
/// @notice The contract is meant to be utilized as a EIP2535 proxy facet. Hence it cannot be called directly and not through
/// the diamond proxy.
contract TDLoupeFacet is BaseFacet, ITDLoupeFacet {

    /// @inheritdoc ITDLoupeFacet
    function getReceiversByAddresses(
        uint256 offset,
        uint256 windowSize,
        address[] memory addresses
    ) external view override delegatedOnly returns (uint256[] memory indicies) {
        uint256 distributionReceiversLength = TDLib.get().distributionReceivers.length;
        if (offset >= distributionReceiversLength) {
            revert TDLib.InvalidOffset(offset);
        }
        indicies = new uint256[](windowSize);
        uint256 coursor;
        bool foundAny;
        for (uint256 i = offset; i < distributionReceiversLength; i++) {
            for (uint256 j = 0; j < addresses.length; j++) {
                if (TDLib.get().distributionReceivers[i].receiver == addresses[j]) {
                    indicies[coursor++] = i;
                    if (!foundAny) foundAny = true;
                }
            }
        }
        if (!foundAny) {
            revert TDLib.NothingWasFound();
        }
    }

    /// @inheritdoc ITDLoupeFacet
    function getReceiversByShares(
        uint256 offset,
        uint256 windowSize,
        uint256[] memory shares
    ) external view override delegatedOnly returns (uint256[] memory indicies) {
        uint256 distributionReceiversLength = TDLib.get().distributionReceivers.length;
        if (offset >= distributionReceiversLength) {
            revert TDLib.InvalidOffset(offset);
        }
        indicies = new uint256[](windowSize);
        uint256 coursor;
        bool foundAny;
        for (uint256 i = offset; i < distributionReceiversLength; i++) {
            for (uint256 j = 0; j < shares.length; j++) {
                if (TDLib.get().distributionReceivers[i].share == shares[j]) {
                    indicies[coursor++] = i;
                    if (!foundAny) foundAny = true;
                }
            }
        }
        if (!foundAny) {
            revert TDLib.NothingWasFound();
        }
    }

    /// @inheritdoc ITDLoupeFacet
    function getReceiversByStatuses(
        uint256 offset,
        uint256 windowSize,
        bool[] memory statuses
    ) external view override delegatedOnly returns (uint256[] memory indicies) {
        uint256 distributionReceiversLength = TDLib.get().distributionReceivers.length;
        if (offset >= distributionReceiversLength) {
            revert TDLib.InvalidOffset(offset);
        }
        indicies = new uint256[](windowSize);
        uint256 coursor;
        bool foundAny;
        for (uint256 i = offset; i < distributionReceiversLength; i++) {
            for (uint256 j = 0; j < statuses.length; j++) {
                if (TDLib.get().distributionReceivers[i].isBlocked == statuses[j]) {
                    indicies[coursor++] = i;
                    if (!foundAny) foundAny = true;
                }
            }
        }
        if (!foundAny) {
            revert TDLib.NothingWasFound();
        }
    }
}
