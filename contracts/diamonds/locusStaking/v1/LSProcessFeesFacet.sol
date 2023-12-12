// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import "../LSLib.sol";
import "../v2/interfaces/ILSWithdrawDequeFacet.sol";
import "../../facetsFramework/diamondBase/facets/BaseFacet.sol";
import "./interfaces/ILSProcessFeesFacet.sol";

contract LSProcessFeesFacet is BaseFacet, ILSProcessFeesFacet {
    using SafeERC20 for IERC20Metadata;

    function processRewardSending(
        address staker,
        uint256 reward,
        WithdrawalsQueueLib.DueDuration dueDuration
    ) external override internalOnly {
        LSLib.Primitives storage p = LSLib.get().p;
        if (address(p.stakingToken) != p.locusToken) {
            ILSWithdrawDequeFacet(address(this)).addDelayedSending(
                staker, reward, dueDuration
            );
        } else {
            p.rewardsToken.safeTransfer(staker, reward);
            emit LSLib.RewardPaid(staker, reward, 0);
        }
    }

    function processWithdrawalSending(
        address staker,
        uint256 amount,
        WithdrawalsQueueLib.DueDuration dueDuration
    ) external override internalOnly {
        LSLib.Primitives storage p = LSLib.get().p;
        if (address(p.stakingToken) == p.locusToken) {
            ILSWithdrawDequeFacet(address(this)).addDelayedSending(
                staker, amount, dueDuration
            );
        } else {
            p.stakingToken.safeTransfer(staker, amount);
            emit LSLib.Withdrawn(staker, amount, 0);
        }
    }
}
