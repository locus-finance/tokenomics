// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";

import "../LSLib.sol";
import "../../facetsFramework/tokensDistributor/TDLib.sol";
import "../../facetsFramework/diamondBase/facets/BaseFacet.sol";
import "../../locusToken/v1/interfaces/ILTERC20Facet.sol";
import "../../locusToken/v1/autocracy/interfaces/ILTAutocracyFacet.sol";

import "./interfaces/ILSProcessFeesFacet.sol";
import "./interfaces/ILSDepositaryFacet.sol";
import "./interfaces/ILSLoupeFacet.sol";

contract LSDepositaryFacet is
    BaseFacet,
    ReentrancyGuardUpgradeable,
    PausableUpgradeable,
    ILSDepositaryFacet
{
    using SafeERC20 for IERC20Metadata;

    function _initialize_LSDepositaryFacet() external initializer override internalOnly {
        __ReentrancyGuard_init();
        __Pausable_init();
    }

    function stakeFor(
        address staker,
        uint256 amount
    ) external override nonReentrant delegatedOnly whenNotPaused {
        RolesManagementLib.enforceSenderRole(LSLib.ALLOWED_TO_STAKE_FOR_ROLE);
        _stake(staker, amount);
    }

    function stake(
        uint256 amount
    ) external override nonReentrant delegatedOnly whenNotPaused {
        _stake(msg.sender, amount);
    }

    function withdraw(
        uint256 amount
    ) public override nonReentrant delegatedOnly {
        updateReward(msg.sender);
        if (amount == 0) revert LSLib.CannotWithdrawZero();
        LSLib.Primitives storage p = LSLib.get().p;
        p.totalSupply -= amount;
        LSLib.get().rt.balanceOf[msg.sender] -= amount;
        IERC20Metadata stakingToken = p.stakingToken;
        uint256 amountWithFees = amount;
        if (address(stakingToken) == p.locusToken) {
            amountWithFees = ILSProcessFeesFacet(address(this))
                .getFeesAccountedAmountAndDistributeFees(
                    amount,
                    stakingToken
                );
        }
        stakingToken.safeTransfer(msg.sender, amountWithFees);
        emit LSLib.Withdrawn(msg.sender, amount, amount - amountWithFees);
    }

    function getReward() public override nonReentrant delegatedOnly {
        updateReward(msg.sender);
        LSLib.Primitives storage p = LSLib.get().p;
        LSLib.ReferenceTypes storage rt = LSLib.get().rt;
        uint256 rawReward = rt.rewards[msg.sender];
        uint256 reward = rawReward;
        if (address(LSLib.get().p.stakingToken) != LSLib.get().p.locusToken) {
            reward = ILSProcessFeesFacet(address(this))
                .getFeesAccountedAmountAndDistributeFees(
                    rawReward,
                    p.rewardsToken
                );
        }
        if (reward > 0) {
            rt.rewards[msg.sender] = 0;
            p.totalReward -= reward;
            p.rewardsToken.safeTransfer(msg.sender, reward);
            emit LSLib.RewardPaid(msg.sender, reward, rawReward - reward);
        }
    }

    function exit() external override {
        withdraw(LSLib.get().rt.balanceOf[msg.sender]);
        getReward();
    }

    function updateReward(address account) public override internalOnly {
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

    function _stake(address staker, uint256 amount) internal {
        updateReward(staker);
        LSLib.Primitives storage p = LSLib.get().p;
        IERC20Metadata stakingToken = p.stakingToken;
        if (amount == 0) revert LSLib.CannotStakeZero();
        TDLib.get().startTimestamps[staker] = uint32(block.timestamp);
        p.totalSupply += amount;
        LSLib.get().rt.balanceOf[staker] += amount;
        stakingToken.safeTransferFrom(
            staker,
            address(this),
            amount
        );
        emit LSLib.Staked(staker, amount);
    }
}
