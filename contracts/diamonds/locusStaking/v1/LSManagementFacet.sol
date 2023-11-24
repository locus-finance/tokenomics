// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import "../LSLib.sol";
import "../../facetsFramework/diamondBase/facets/BaseFacet.sol";
import "./interfaces/ILSManagementFacet.sol";
import "./interfaces/ILSDepositaryFacet.sol";

contract LSManagementFacet is BaseFacet, ILSManagementFacet {
    using SafeERC20 for IERC20Metadata;

    function notifyRewardAmount(
        uint256 reward
    ) external override delegatedOnly {
        RolesManagementLib.enforceSenderRole(LSLib.REWARD_DISTRIBUTOR_ROLE);
        ILSDepositaryFacet(address(this)).updateReward(address(0));

        LSLib.Primitives storage p = LSLib.get().p;

        p.rewardsToken.safeTransferFrom(msg.sender, address(this), reward);
        p.totalReward += reward;

        if (block.timestamp >= p.periodFinish) {
            p.rewardRate = reward / p.rewardsDuration;
        } else {
            uint256 remaining = p.periodFinish - block.timestamp;
            uint256 leftover = remaining * p.rewardRate;
            p.rewardRate = (reward + leftover) / p.rewardsDuration;
        }

        // Ensure the provided reward amount is not more than the balance in the contract.
        // This keeps the reward rate in the right range, preventing overflows due to
        // very high values of rewardRate in the earned and rewardsPerToken functions;
        // Reward + leftover must be less than 2^256 / 10^18 to avoid overflow.
        if (p.rewardRate > p.totalReward / p.rewardsDuration) {
            revert LSLib.RewardIsTooHigh(p.totalReward);
        }

        p.lastUpdateTime = block.timestamp;
        p.periodFinish = block.timestamp + p.rewardsDuration;
        emit LSLib.RewardAdded(reward);
    }

    function recoverTokens(
        address tokenAddress,
        uint256 tokenAmount
    ) external override delegatedOnly {
        RolesManagementLib.enforceSenderRole(RolesManagementLib.OWNER_ROLE);
        if (tokenAddress == address(LSLib.get().p.stakingToken)) {
            revert LSLib.CannotRecoverToken(tokenAddress, tokenAmount);
        }
        IERC20Metadata(tokenAddress).safeTransfer(msg.sender, tokenAmount);
        emit LSLib.Recovered(tokenAddress, tokenAmount);
    }
    
    function setRewardsDuration(
        uint256 _rewardsDuration
    ) external override delegatedOnly {
        RolesManagementLib.enforceSenderRole(RolesManagementLib.OWNER_ROLE);
        LSLib.Primitives storage p = LSLib.get().p;
        if (block.timestamp <= p.periodFinish) {
            revert LSLib.ChangingRewardsDurationTooEarly(
                p.periodFinish - block.timestamp
            );
        }
        p.rewardsDuration = _rewardsDuration;
        emit LSLib.RewardsDurationUpdated(_rewardsDuration);
    }
}
