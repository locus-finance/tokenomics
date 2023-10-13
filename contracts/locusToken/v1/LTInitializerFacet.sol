// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "./interfaces/ILTInitializerFacet.sol";
import "../LTLib.sol";
import "../../diamondBase/facets/BaseFacet.sol";

contract LTInitializerFacet is BaseFacet, ILTInitializerFacet {
    function initialize() external override {
        InitializerLib.initialize();
        LTLib.Primitives storage p = LTLib.get().p;
        p.startEpochTime = block.timestamp + LTLib.INFLATION_DELAY - LTLib.RATE_REDUCTION_TIME;
        p.miningEpoch = -1;
        p.rate = 0;
        p.startEpochSupply = LTLib.INITIAL_SUPPLY;
    }
}