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
        IASReflectionFacet(address(this))._mintTo(msg.sender, amount);
        IERC20(ASLib.get().p.stakingToken).safeTransferFrom(
            msg.sender,
            address(this),
            amount
        );
        emit Staked(amount);
    }

    function withdraw(uint256 amount) external override delegatedOnly {
        ASLib.Primitives storage p = ASLib.get().p;
        IASReflectionFacet(address(this))._burnFrom(msg.sender, amount);
        IERC20(p.rewardToken).safeTransfer(msg.sender, amount);
        emit Withdrawn(amount);
    }

    function notifyRewardAmount(
        uint256 amount
    ) external override delegatedOnly {
        RolesManagementLib.enforceSenderRole(RolesManagementLib.OWNER_ROLE);
        ASLib.Primitives storage p = ASLib.get().p;
        IERC20(p.rewardToken).safeTransferFrom(
            msg.sender,
            address(this),
            amount
        );
        p.totalReward += amount;
        p.tTotal += amount;
        IASReflectionFacet(address(this))._updateTotalReflection();
        emit RewardAdded(amount);
    }
}
