// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "../../facetsFramework/diamondBase/facets/BaseFacet.sol";
import "../ASLib.sol";

contract ASDepositaryFacet is BaseFacet {
    function stake(uint256 amount) external delegatedOnly {
        // transfer staking token
        // register starting balance and time
        // mint
    }

    function withdraw(uint256 amount) external delegatedOnly {
        // get starting balance
        // call reflect
        // calculate difference between starting and current balance
        // transfer starting balance + difference of balances
        // burn whole balance
        // mint amount and refresh starting balance and time
    }
}
