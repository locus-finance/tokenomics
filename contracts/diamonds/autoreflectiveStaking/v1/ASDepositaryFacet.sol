// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import "../../facetsFramework/diamondBase/facets/BaseFacet.sol";
import "../ASLib.sol";
import "./interfaces/IASReflectionFacet.sol";
import "./interfaces/IASDepositaryFacet.sol";

contract ASDepositaryFacet is IASDepositaryFacet, BaseFacet {
    using SafeERC20 for IERC20;

    function stake(uint256 amount) external override delegatedOnly {
        // transfer staking token
        IERC20(ASLib.get().p.stakingToken).safeTransferFrom(
            msg.sender,
            address(this),
            amount
        );
        // register starting balance and time
        ASLib.ReferenceTypes storage rt = ASLib.get().rt;
        uint256 oldAmount = rt.depositAtStartFor[msg.sender].amount;
        if (oldAmount != 0) {
            rt.depositAtStartFor[msg.sender] = ASLib.Deposit({
                amount: oldAmount + amount,
                timestamp: block.timestamp
            });
        } else {
            rt.depositAtStartFor[msg.sender] = ASLib.Deposit({
                amount: amount,
                timestamp: block.timestamp
            });
        }
        // mint
        IASReflectionFacet(address(this))._mintTo(msg.sender, amount);
        emit Staked(amount);
    }

    function withdraw(uint256 amount) external override delegatedOnly {
        // get starting balance
        // call reflect
        // calculate difference between starting and current balance
        // transfer starting balance + difference of balances
        // update totalReward
        // burn whole balance
        // mint amount and refresh starting balance and time
    }

    function notifyRewardAmount(
        uint256 amount
    ) external override delegatedOnly {
        RolesManagementLib.enforceSenderRole(RolesManagementLib.OWNER_ROLE);
        // transfer from the caller staking tokens
        IERC20(ASLib.get().p.rewardToken).safeTransferFrom(
            msg.sender,
            address(this),
            amount
        );
        // update total reward
        ASLib.get().p.totalReward += amount;
        emit RewardAdded(amount);
    }
}
