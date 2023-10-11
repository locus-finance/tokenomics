// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "./interfaces/IVEInitializerFacet.sol";
import "./interfaces/IVEDepositaryFacet.sol";
import "../VELib.sol";
import "../../diamondBase/facets/BaseFacet.sol";

contract VEInitializerFacet is BaseFacet, IVEInitializerFacet {
    function initialize(
        address owner,
        uint256 minLockDuration,
        address locusToken
    ) external override delegatedOnly {
        InitializerLib.initialize();
        IVEDepositaryFacet(address(this))._initialize_VEDepositaryFacet();
        RolesManagementLib.grantRole(owner, RolesManagementLib.OWNER_ROLE);
        VELib.Primitives storage p = VELib.get().p;
        VELib.ReferenceTypes storage rt = VELib.get().rt;
        rt.pointHistory[0].blk = block.number;
        rt.pointHistory[0].ts = block.timestamp;
        p.locusToken = locusToken;
        if (minLockDuration >= VELib.MAXTIME) revert VELib.MaxTimeHit();
        p.minLockDuration = minLockDuration;
    }
}
