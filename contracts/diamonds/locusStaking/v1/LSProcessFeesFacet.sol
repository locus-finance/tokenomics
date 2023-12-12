// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import "../LSLib.sol";
import "../../facetsFramework/diamondBase/facets/BaseFacet.sol";
import "./interfaces/ILSProcessFeesFacet.sol";

contract LSProcessFeesFacet is BaseFacet, ILSProcessFeesFacet {
    using SafeERC20 for IERC20Metadata;

    struct DelayedSending {
        uint256 amount;
        uint256 dueToTimestamp;
    }

    function processRewardSending(
        address staker,
        uint256 reward,
        LSLib.DueDuration dueDuration
    ) external override internalOnly {
        LSLib.Primitives storage p = LSLib.get().p;
        if (address(p.stakingToken) != p.locusToken) {

        } else {
            p.rewardsToken.safeTransfer(staker, reward);
            emit LSLib.RewardPaid(staker, reward, 0);
        }
    }

    function processWithdrawalSending(
        address staker,
        uint256 amount,
        LSLib.DueDuration dueDuration
    ) external override internalOnly {
        LSLib.Primitives storage p = LSLib.get().p;
        if (address(p.stakingToken) == p.locusToken) {

        } else {
            p.stakingToken.safeTransfer(staker, amount);
            emit LSLib.Withdrawn(staker, amount, 0);
        }
    }
}
