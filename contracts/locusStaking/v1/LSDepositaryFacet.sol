// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/PausableUpgradeable.sol";

import "./feesManagement/interfaces/ILSProcessFeesFacet.sol";
import "./feesManagement/libraries/LSFeesLib.sol";
import "../LSLib.sol";
import "../../diamondBase/facets/BaseFacet.sol";
import "./interfaces/ILSDepositaryFacet.sol";
import "./interfaces/ILSLoupeFacet.sol";

contract LSDepositaryFacet is
    BaseFacet,
    ReentrancyGuardUpgradeable,
    PausableUpgradeable,
    ILSDepositaryFacet
{
    using SafeERC20 for IERC20;

    function _initialize_LSDepositaryFacet() external override internalOnly {
        __ReentrancyGuard_init();
        __Pausable_init();
    }

    function stake(
        uint256 amount
    ) external override nonReentrant delegatedOnly whenNotPaused {
        updateReward(msg.sender);
        if (amount == 0) revert LSLib.CannotStakeZero();
        LSFeesLib.get().stakerToStartStakingTimestamp[msg.sender] = uint32(block.timestamp);
        LSLib.get().p.totalSupply += amount;
        LSLib.get().rt.balanceOf[msg.sender] += amount;
        LSLib.get().p.stakingToken.safeTransferFrom(
            msg.sender,
            address(this),
            amount
        );
        emit LSLib.Staked(msg.sender, amount);
    }

    function withdraw(
        uint256 amount
    ) public override nonReentrant delegatedOnly {
        updateReward(msg.sender);
        if (amount == 0) revert LSLib.CannotWithdrawZero();
        LSLib.get().p.totalSupply -= amount;
        LSLib.get().rt.balanceOf[msg.sender] -= amount;
        LSLib.get().p.stakingToken.safeTransfer(msg.sender, amount);
        emit LSLib.Withdrawn(msg.sender, amount);
    }

    function getReward() public override nonReentrant delegatedOnly {
        updateReward(msg.sender);
        LSLib.Primitives storage p = LSLib.get().p;
        LSLib.ReferenceTypes storage rt = LSLib.get().rt;
        uint256 reward = ILSProcessFeesFacet(address(this))
            .getFeesAccountedRewardAndDistributeFees(rt.rewards[msg.sender], p.rewardsToken);
        if (reward > 0) {
            rt.rewards[msg.sender] = 0;
            p.totalReward -= reward;
            p.rewardsToken.safeTransfer(msg.sender, reward);
            emit LSLib.RewardPaid(msg.sender, reward);
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
}
