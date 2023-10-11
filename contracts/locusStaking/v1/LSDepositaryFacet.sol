// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "../LSLib.sol";
import "../../diamondBase/facets/BaseFacet.sol";
import "./interfaces/ILSDepositaryFacet.sol";

contract LSDepositaryFacet is BaseFacet, ILSDepositaryFacet {
    function stake(
        uint256 amount
    ) external nonReentrant whenNotPaused updateReward(_msgSender()) {
        if (amount == 0) revert CannotStakeZero();
        totalSupply += amount;
        balanceOf[_msgSender()] += amount;
        stakingToken.safeTransferFrom(_msgSender(), address(this), amount);
        emit Staked(_msgSender(), amount);
    }

    function withdraw(
        uint256 amount
    ) public nonReentrant updateReward(_msgSender()) {
        if (amount == 0) revert CannotWithdrawZero();
        totalSupply -= amount;
        balanceOf[_msgSender()] -= amount;
        stakingToken.safeTransfer(_msgSender(), amount);
        emit Withdrawn(_msgSender(), amount);
    }

    function getReward() public nonReentrant updateReward(_msgSender()) {
        uint256 reward = rewards[_msgSender()];
        if (reward > 0) {
            rewards[_msgSender()] = 0;
            totalReward -= reward;
            rewardsToken.safeTransfer(_msgSender(), reward);
            emit RewardPaid(_msgSender(), reward);
        }
    }

    function exit() external {
        withdraw(balanceOf[_msgSender()]);
        getReward();
    }
}