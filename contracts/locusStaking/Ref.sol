// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract LocusStaking is ReentrancyGuard, Pausable, AccessControl {
    using SafeERC20 for IERC20;

    constructor(
        address _rewardsDistributor,
        address _rewardsToken,
        address _stakingToken
    ) {
        rewardsToken = IERC20(_rewardsToken);
        stakingToken = IERC20(_stakingToken);
        _grantRole(REWARDS_DISTRIBUTOR_ROLE, _rewardsDistributor);
        _grantRole(DEFAULT_ADMIN_ROLE, _msgSender());
    }

    function lastTimeRewardApplicable() public view returns (uint256) {
        return block.timestamp < periodFinish ? block.timestamp : periodFinish;
    }

    function rewardPerToken() public view returns (uint256) {
        if (totalSupply == 0) {
            return rewardPerTokenStored;
        }
        return
            rewardPerTokenStored +
            (((lastTimeRewardApplicable() - lastUpdateTime) *
                rewardRate *
                PRECISION) / totalSupply);
    }

    function earned(address account) public view returns (uint256) {
        return
            (balanceOf[account] *
                (rewardPerToken() - userRewardPerTokenPaid[account])) /
            PRECISION +
            rewards[account];
    }

    function getRewardForDuration() external view returns (uint256) {
        return rewardRate * rewardsDuration;
    }

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

    function notifyRewardAmount(
        uint256 reward
    ) external onlyRole(REWARDS_DISTRIBUTOR_ROLE) updateReward(address(0)) {
        rewardsToken.safeTransferFrom(_msgSender(), address(this), reward);
        totalReward += reward;

        if (block.timestamp >= periodFinish) {
            rewardRate = reward / rewardsDuration;
        } else {
            uint256 remaining = periodFinish - block.timestamp;
            uint256 leftover = remaining * rewardRate;
            rewardRate = (reward + leftover) / rewardsDuration;
        }

        // Ensure the provided reward amount is not more than the balance in the contract.
        // This keeps the reward rate in the right range, preventing overflows due to
        // very high values of rewardRate in the earned and rewardsPerToken functions;
        // Reward + leftover must be less than 2^256 / 10^18 to avoid overflow.
        if (rewardRate > totalReward / rewardsDuration) {
            revert RewardIsTooHigh(totalReward);
        }

        lastUpdateTime = block.timestamp;
        periodFinish = block.timestamp + rewardsDuration;
        emit RewardAdded(reward);
    }

    function recoverTokens(
        address tokenAddress,
        uint256 tokenAmount
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        if (tokenAddress == address(stakingToken)) {
            revert CannotRecoverToken(tokenAddress, tokenAmount);
        }
        IERC20(tokenAddress).safeTransfer(_msgSender(), tokenAmount);
        emit Recovered(tokenAddress, tokenAmount);
    }

    function setRewardsDuration(
        uint256 _rewardsDuration
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        if (block.timestamp <= periodFinish) {
            revert ChangingRewardsDurationTooEarly(
                periodFinish - block.timestamp
            );
        }
        rewardsDuration = _rewardsDuration;
        emit RewardsDurationUpdated(rewardsDuration);
    }

    function _updateReward(address account) internal {
        rewardPerTokenStored = rewardPerToken();
        lastUpdateTime = lastTimeRewardApplicable();
        if (account != address(0)) {
            rewards[account] = earned(account);
            userRewardPerTokenPaid[account] = rewardPerTokenStored;
        }
    }
}
