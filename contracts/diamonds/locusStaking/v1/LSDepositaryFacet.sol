// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";

import "../LSLib.sol";
import "../../facetsFramework/diamondBase/facets/BaseFacet.sol";
import "../../facetsFramework/diamondBase/facets/PausabilityFacet.sol";

import "../../locusToken/v1/interfaces/ILTERC20Facet.sol";
import "../../locusToken/v1/autocracy/interfaces/ILTAutocracyFacet.sol";

import "../v2/manualWithdrawQueueFacets/libraries/DelayedSendingsQueueLib.sol";

import "./interfaces/ILSProcessFeesFacet.sol";
import "./interfaces/ILSDepositaryFacet.sol";
import "./interfaces/ILSLoupeFacet.sol";

contract LSDepositaryFacet is
    BaseFacet,
    PausabilityFacet,
    ReentrancyGuardUpgradeable,
    ILSDepositaryFacet
{
    using SafeERC20 for IERC20Metadata;

    function _initialize_LSDepositaryFacet()
        external
        override
        initializer
        internalOnly
    {
        __ReentrancyGuard_init();
    }

    function stakeFor(
        address staker,
        uint256 amount
    ) external override nonReentrant delegatedOnly whenNotPaused {
        RolesManagementLib.enforceSenderRole(LSLib.ALLOWED_TO_STAKE_FOR_ROLE);
        _stake(staker, msg.sender, amount);
    }

    function stake(
        uint256 amount
    ) external override nonReentrant delegatedOnly whenNotPaused {
        _stake(msg.sender, msg.sender, amount);
    }

    function withdraw(
        uint256 amount,
        DelayedSendingsQueueLib.DueDuration dueDuration
    ) public override nonReentrant delegatedOnly {
        ILSDepositaryFacet(address(this)).updateReward(msg.sender);
        if (amount == 0) revert LSLib.CannotWithdrawZero();
        LSLib.Primitives storage p = LSLib.get().p;
        p.totalSupply -= amount;
        LSLib.get().rt.balanceOf[msg.sender] -= amount;
        ILSProcessFeesFacet(address(this)).processWithdrawalSending(
            msg.sender,
            amount,
            dueDuration
        );
    }

    function getReward(
        DelayedSendingsQueueLib.DueDuration dueDuration
    ) public override nonReentrant delegatedOnly {
        _getReward(dueDuration);
    }

    function updateReward(address account) public override internalOnly {
        _updateReward(account);
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
        LSLib.get().p.rewardPerTokenStored = self.rewardPerToken();
        LSLib.get().p.lastUpdateTime = self.lastTimeRewardApplicable();
        if (account != address(0)) {
            LSLib.get().rt.rewards[account] = self.earned(account);
            LSLib.get().rt.userRewardPerTokenPaid[account] = LSLib
                .get()
                .p
                .rewardPerTokenStored;
        }
    }

    function _stake(
        address staker,
        address fundsOwner,
        uint256 amount
    ) internal {
        ILSDepositaryFacet(address(this)).updateReward(staker);
        LSLib.Primitives storage p = LSLib.get().p;
        IERC20Metadata stakingToken = p.stakingToken;
        if (amount == 0) revert LSLib.CannotStakeZero();
        p.totalSupply += amount;
        LSLib.get().rt.balanceOf[staker] += amount;
        stakingToken.safeTransferFrom(fundsOwner, address(this), amount);
        emit LSLib.Staked(staker, amount);
    }
}
