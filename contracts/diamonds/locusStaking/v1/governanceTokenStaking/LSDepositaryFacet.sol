// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import "../../../../notDiamonds/interfaces/IWrappedStakingLocus.sol";
import "../../LSLib.sol";
import "../../v2/manualWithdrawQueueFacets/libraries/DelayedSendingsQueueLib.sol";
import "../interfaces/ILSGeneralDepositaryFacet.sol";

contract LSDepositaryFacet is ILSGeneralDepositaryFacet {
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

    function _stake(
        address staker,
        address fundsOwner,
        uint256 amount
    ) internal override {
        _updateReward(staker);
        LSLib.Primitives storage p = LSLib.get().p;
        IERC20Metadata stakingToken = p.stakingToken;
        if (amount == 0) revert LSLib.CannotStakeZero();
        p.totalSupply += amount;
        LSLib.get().rt.balanceOf[staker] += amount;
        stakingToken.safeTransferFrom(fundsOwner, address(this), amount);
        emit LSLib.Staked(staker, amount);
        if (p.wrappedStLocusToken != address(0)) {
            IWrappedStakingLocus(p.wrappedStLocusToken).syncBalanceOnStake(
                staker
            );
        }
    }
}
