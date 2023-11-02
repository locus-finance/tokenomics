// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import "./interfaces/ILSProcessFeesFacet.sol";
import "../LSLib.sol";
import "../../diamondBase/facets/BaseFacet.sol";
import "../../tokensDistributor/TDLib.sol";
import "../../tokensDistributor/v1/interfaces/ITDProcessFacet.sol";

contract LSProcessFeesFacet is BaseFacet, ILSProcessFeesFacet {
    using SafeERC20 for IERC20;

    function getFeesAccountedAmountAndDistributeFees(
        uint256 reward,
        IERC20 rewardsToken
    ) external override internalOnly returns (uint256 feesSubstractedReward) {
        (uint256 feeBps,) = TDLib.getAmountToDistribute(msg.sender);
        if (feeBps == 0) {
            return reward;
        }
        uint256 feeAmountGathered = (reward * feeBps) / TDLib.MAX_BPS;
        feesSubstractedReward = reward - feeAmountGathered;
        ITDProcessFacet(address(this)).distribute(
            feeAmountGathered,
            rewardsToken
        );
    }
}
