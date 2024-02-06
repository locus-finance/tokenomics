// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";

import "../../../notDiamonds/interfaces/IWrappedStakingLocus.sol";

import "../LSLib.sol";
import "../../facetsFramework/diamondBase/facets/BaseFacet.sol";
import "../../facetsFramework/diamondBase/facets/PausabilityFacet.sol";

import "../../locusToken/v1/interfaces/ILTERC20Facet.sol";
import "../../locusToken/v1/autocracy/interfaces/ILTAutocracyFacet.sol";

import "../v2/manualWithdrawQueueFacets/libraries/DelayedSendingsQueueLib.sol";

import "./interfaces/ILSProcessFeesFacet.sol";
import "./interfaces/ILSDepositaryFacet.sol";
import "./interfaces/ILSLoupeFacet.sol";

import "hardhat/console.sol";

contract LSDepositaryForVaultTokensFacet is
    BaseFacet,
    PausabilityFacet,
    ReentrancyGuardUpgradeable,
    ILSDepositaryFacet
{
    using SafeERC20 for IERC20Metadata;

    function withdraw(
        uint256 amount,
        DelayedSendingsQueueLib.DueDuration dueDuration
    ) public override nonReentrant delegatedOnly {
        _updateReward(msg.sender);
        if (amount == 0) revert LSLib.CannotWithdrawZero();
        LSLib.Primitives storage p = LSLib.get().p;
        p.totalSupply -= amount;
        LSLib.get().rt.balanceOf[msg.sender] -= amount;
        ILSProcessFeesFacet(address(this)).processWithdrawalSending(
            msg.sender,
            amount,
            dueDuration
        );
        if (p.wrappedStLocusToken != address(0)) {
            IWrappedStakingLocus(p.wrappedStLocusToken).syncBalanceOnWithdraw(msg.sender);
        }
    }

    function _getReward(DelayedSendingsQueueLib.DueDuration dueDuration) internal {
        _updateReward(msg.sender);
        LSLib.Primitives storage p = LSLib.get().p;
        LSLib.ReferenceTypes storage rt = LSLib.get().rt;
        uint256 reward = rt.rewards[msg.sender];
        if (reward > 0) {
            rt.rewards[msg.sender] = 0;
            p.totalReward -= reward;
            ILSProcessFeesFacet(address(this)).processRewardSending(
                msg.sender,
                reward,
                dueDuration
            );
        }
    }

    function _updateReward(address account) internal {
        ILSLoupeFacet self = ILSLoupeFacet(address(this));
        LSLib.Primitives storage p = LSLib.get().p;
        LSLib.ReferenceTypes storage rt = LSLib.get().rt;
        p.rewardPerTokenStored = self.rewardPerToken();
        p.lastUpdateTime = self.lastTimeRewardApplicable();
        if (account != address(0)) {
            rt.rewards[account] = self.earned(account);
            rt.userRewardPerTokenPaid[account] = p.rewardPerTokenStored;
        }
    }

    function _stake(
        address staker,
        address fundsOwner,
        uint256 amount
    ) internal {
        _updateReward(staker);
        LSLib.Primitives storage p = LSLib.get().p;
        IERC20Metadata stakingToken = p.stakingToken;
        if (amount == 0) revert LSLib.CannotStakeZero();
        p.totalSupply += amount;
        LSLib.get().rt.balanceOf[staker] += amount;
        stakingToken.safeTransferFrom(fundsOwner, address(this), amount);
        emit LSLib.Staked(staker, amount);
        if (p.wrappedStLocusToken != address(0)) {
            IWrappedStakingLocus(p.wrappedStLocusToken).syncBalanceOnStake(staker);
        }
    }
}
