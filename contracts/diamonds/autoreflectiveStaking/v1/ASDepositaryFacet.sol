// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import "../../facetsFramework/diamondBase/facets/BaseFacet.sol";
import "../ASLib.sol";

contract ASDepositaryFacet is BaseFacet {
    using SafeERC20 for IERC20;

    function stake(uint256 amount) external delegatedOnly {
        ASLib.Primitives storage p = ASLib.get().p;
        
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
