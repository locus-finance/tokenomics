// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "../LSLib.sol";
import "../../facetsFramework/diamondBase/facets/BaseFacet.sol";
import "../../facetsFramework/tokensDistributor/TDLib.sol";
import "./interfaces/ILSLoupeFacet.sol";
import "./interfaces/ILSERC20Facet.sol";

contract LSLoupeFacet is BaseFacet, ILSLoupeFacet {
    function lastTimeRewardApplicable()
        public
        view
        override
        delegatedOnly
        returns (uint256)
    {
        return
            block.timestamp < LSLib.get().p.periodFinish
                ? block.timestamp
                : LSLib.get().p.periodFinish;
    }

    function rewardPerToken()
        public
        view
        override
        delegatedOnly
        returns (uint256)
    {
        LSLib.Primitives memory p = LSLib.get().p;
        if (p.totalSupply == 0) {
            return p.rewardPerTokenStored;
        }
        return
            p.rewardPerTokenStored +
            (((lastTimeRewardApplicable() - p.lastUpdateTime) *
                p.rewardRate *
                LSLib.PRECISION) / p.totalSupply);
    }

    function earned(
        address account
    ) external view override delegatedOnly returns (uint256) {
        LSLib.ReferenceTypes storage rt = LSLib.get().rt;
        return
            (rt.balanceOf[account] *
                (rewardPerToken() - rt.userRewardPerTokenPaid[account])) /
            LSLib.PRECISION +
            rt.rewards[account];
    }

    function getCurrentFeeBps(
        address staker
    ) external view override delegatedOnly returns (uint256 feeBps) {
        (feeBps, ) = TDLib.getAmountToDistribute(staker);
    }

    function getTimeOfLastStake(
        address staker
    ) external view override delegatedOnly returns (uint32) {
        return TDLib.get().startTimestamps[staker];
    }

    function getRewardForDuration()
        external
        view
        override
        delegatedOnly
        returns (uint256)
    {
        LSLib.Primitives memory p = LSLib.get().p;
        return p.rewardRate * p.rewardsDuration;
    }

    function getProjectedAPR(
        uint256 rewardRate,
        uint256 rewardDuration
    ) external view override delegatedOnly returns (uint256) {
        return _getProjectedAPR(rewardRate, rewardDuration);
    }

    function getAPR() external view override delegatedOnly returns (uint256) {
        LSLib.Primitives memory p = LSLib.get().p;
        return _getProjectedAPR(p.rewardRate, p.rewardDuration);
    }

    function _getProjectedAPR(
        uint256 rewardRate,
        uint256 rewardDuration
    ) internal view returns (uint256) {
        LSLib.Primitives memory p = LSLib.get().p;
        uint256 decimals = ILSERC20Facet(address(this)).decimals();
        uint256 oneToken = 10 ** decimals;
        uint256 accumulatedRewardsIfOneTokenStaked = 
            oneToken *
            (
                (
                    (rewardRate * rewardDuration * LSLib.PRECISION) / p.totalSupply
                ) / LSLib.PRECISION
            );
        return (
            (TDLib.MAX_BPS * accumulatedRewardsIfOneTokenStaked * LSLib.PRECISION) / oneToken
        ) / LSLib.PRECISION;
    }
}
