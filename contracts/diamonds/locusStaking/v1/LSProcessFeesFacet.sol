// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import "../LSLib.sol";
import "../../facetsFramework/diamondBase/facets/BaseFacet.sol";
import "../../facetsFramework/tokensDistributor/TDLib.sol";
import "../../facetsFramework/tokensDistributor/v1/interfaces/ITDProcessFacet.sol";

import "./interfaces/ILSProcessFeesFacet.sol";

contract LSProcessFeesFacet is BaseFacet, ILSProcessFeesFacet {
    using SafeERC20 for IERC20Metadata;

    function getFeesAccountedAmountAndDistributeFees(
        uint256 reward,
        IERC20Metadata rewardsToken
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
