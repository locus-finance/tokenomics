// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "./interfaces/ILTEmissionControlFacet.sol";
import "../LTLib.sol";
import "../../diamondBase/facets/BaseFacet.sol";
import "../../tokensDistributor/TDLib.sol";

contract LTEmissionControlFacet is BaseFacet {
    function mintInflation() external delegatedOnly {
        // NEED TO KNOW: A role of middleman is occupied by the locusStaking diamond only,
        // because we do not need a functionality of middlemen in tokenDistributor diamond.
        // uint256 amountToDistributeInThisEpoch = TDLib.getAmountToDistribute(msg.sender, address(this));
        // if (feeBps == 0) {
        //     return;
        // }
        // ITDProcessFacet(address(this)).distribute(
        //     feeAmountGathered,
        //     rewardsToken
        // );
    }
}
