// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "../../facetsFramework/diamondBase/facets/BaseFacet.sol";
import "../ASLib.sol";

contract ASDepositaryFacet is BaseFacet {
    function stake(uint256 amount) external delegatedOnly {

    }

    function withdraw(uint256 amount) external delegatedOnly {
        
    }
}
