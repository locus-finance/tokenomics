// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "../VELib.sol";
import "../../diamondBase/facets/BaseFacet.sol";
import "./interfaces/IVEManagementFacet.sol";

contract VEManagementFacet is BaseFacet, IVEManagementFacet {
    function setLocusToken(
        address _locusToken
    ) external override delegatedOnly {
        RolesManagementLib.enforceSenderRole(RolesManagementLib.OWNER_ROLE);
        VELib.get().p.locusToken = _locusToken;
    }

    function setMinLockDuration(
        uint256 _minLockDuration
    ) external override delegatedOnly {
        bytes32[] memory roles = new bytes32[](2);
        roles[0] = RolesManagementLib.OWNER_ROLE;
        roles[1] = RolesManagementLib.INTERNAL_ROLE;
        RolesManagementLib.enforceSenderEitherOfRoles(roles);

        if (_minLockDuration >= VELib.MAXTIME) revert VELib.MaxTimeHit();
        VELib.get().p.minLockDuration = _minLockDuration;
    }

    /// @notice Get the most recently recorded rate of voting power decrease for `addr`.
    /// @param addr Address of the user wallet
    /// @return Value of the slope
    function getLastUserSlope(
        address addr
    ) external view override delegatedOnly returns (int128) {
        return
            VELib
            .get()
            .rt
            .userPointHistory[addr][VELib.get().rt.userPointEpoch[addr]].slope;
    }

    /// @notice Get the timestamp for checkpoint `idx` for `addr`.
    /// @param addr User wallet address
    /// @param idx User epoch number
    /// @return Epoch time of the checkpoint
    function userPointHistoryTs(
        address addr,
        uint256 idx
    ) external view override delegatedOnly returns (uint256) {
        return VELib.get().rt.userPointHistory[addr][idx].ts;
    }
}
