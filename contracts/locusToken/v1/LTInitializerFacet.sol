// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "./interfaces/ILTInitializerFacet.sol";
import "../LTLib.sol";
import "../../diamondBase/facets/BaseFacet.sol";

contract LTInitializerFacet is BaseFacet, ILTInitializerFacet {
    function initialize() external override {
        InitializerLib.initialize();
    }
}