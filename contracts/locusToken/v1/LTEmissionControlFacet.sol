// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "./interfaces/ILTEmissionControlFacet.sol";
import "../LTLib.sol";
import "../../diamondBase/facets/BaseFacet.sol";

contract LTEmissionControlFacet is BaseFacet {
    function _initialize_LTEmissionControlFacet(
        uint256 epochDuration,
        uint256[] calldata bondingCurvePoints 
    ) external internalOnly {
        LTLib.ReferenceTypes storage rt = LTLib.get().rt;
        for (uint256 i; i < bondingCurvePoints.length; i++) {
            rt.epochNumberToInlfationAmount[i] = bondingCurvePoints[i]; 
        }
        LTLib.get().p.epochDuration = epochDuration;
    }

    function mintInflation() external delegatedOnly {

    }
}
