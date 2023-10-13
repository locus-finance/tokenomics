// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "../LGLib.sol";
import "../../diamondBase/facets/BaseFacet.sol";
import "./interfaces/ILGInitializerFacet.sol";

contract LGInitializerFacet is BaseFacet, ILGInitializerFacet {
    function initialize(
        address vaultToken,
        address locusToken,
        address controller,
        address votingEscrow
    ) external {
        InitializerLib.initialize();
        LGLib.Primitives storage p = LGLib.get().p;
        p.locusToken = locusToken;
        p.vaultToken = vaultToken;
        p.controller = controller;
        p.votingEscrow = votingEscrow;
        LGLib.get().rt.periodTimestamp[0] = block.timestamp;
        // p.inflationRate = CRV20(crv_addr).rate()
        // p.futureEpochTime = CRV20(crv_addr).future_epoch_time_write()
    }
}