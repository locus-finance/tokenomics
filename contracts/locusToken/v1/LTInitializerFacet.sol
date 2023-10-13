// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "./interfaces/ILTInitializerFacet.sol";
import "../LTLib.sol";
import "../../diamondBase/facets/BaseFacet.sol";

contract LTInitializerFacet is BaseFacet, ILTInitializerFacet {
    function initialize() external override {
        InitializerLib.initialize();
        LTLib.Storage storage s = LTLib.get();
        s.startEpochTime = block.timestamp + LTLib.INFLATION_DELAY - LTLib.RATE_REDUCTION_TIME;
        s.miningEpoch = -1;
        s.rate = 0;
        s.startEpochSupply = LTLib.INITIAL_SUPPLY;
    }
}