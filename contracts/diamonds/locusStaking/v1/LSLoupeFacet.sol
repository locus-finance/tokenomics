// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

import "../LSLib.sol";
import "../../facetsFramework/diamondBase/facets/BaseFacet.sol";
import "../../facetsFramework/tokensDistributor/TDLib.sol";
import "./interfaces/ILSLoupeFacet.sol";

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

    function getTotalReward()
        external
        view
        override
        delegatedOnly
        returns (uint256)
    {
        return LSLib.get().p.totalReward;
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

    function totalSupply() external view override delegatedOnly returns (uint256) {
        return LSLib.get().p.totalSupply;
    }

    function balanceOf(
        address account
    ) external view override delegatedOnly returns (uint256) {
        return LSLib.get().rt.balanceOf[account];
    }

    function name() external view override delegatedOnly returns (string memory) {
        return string(abi.encodePacked("Staking ", LSLib.get().p.stakingToken.name()));
    }

    function symbol() external view override delegatedOnly returns (string memory) {
        return string(abi.encodePacked("st", LSLib.get().p.stakingToken.symbol()));
    }

    function decimals() external view override delegatedOnly returns (uint8) {
        return LSLib.get().p.stakingToken.decimals();
    }

    function getProjectedAPR(
        uint256 rewardRate,
        uint256 rewardDuration
    ) external view override delegatedOnly returns (uint256) {
        return _getProjectedAPR(rewardRate, rewardDuration);
    }

    function getAPR() external view override delegatedOnly returns (uint256) {
        LSLib.Primitives memory p = LSLib.get().p;
        return _getProjectedAPR(p.rewardRate, p.rewardsDuration);
    }

    function getAPRInAbsoluteValue()
        external
        view
        override
        delegatedOnly
        returns (uint256)
    {
        LSLib.Primitives memory p = LSLib.get().p;
        return
            _getProjectedAPRInAbsoluteValue(p.rewardRate, p.rewardsDuration) /
            LSLib.PRECISION;
    }

    function _getProjectedAPRInAbsoluteValue(
        uint256 rewardRate,
        uint256 rewardDuration
    )
        internal
        view
        returns (uint256 accumulatedRewardsIfOneTokenStakedWithPrecision)
    {
        LSLib.Primitives memory p = LSLib.get().p;
        uint256 oneToken = 10 ** IERC20Metadata(address(this)).decimals();
        accumulatedRewardsIfOneTokenStakedWithPrecision =
            oneToken *
            ((rewardRate * rewardDuration * LSLib.PRECISION) / p.totalSupply);
    }

    function _getProjectedAPR(
        uint256 rewardRate,
        uint256 rewardDuration
    ) internal view returns (uint256) {
        uint256 oneToken = 10 ** IERC20Metadata(address(this)).decimals();
        uint256 accumulatedRewardsIfOneTokenStakedWithPrecision = _getProjectedAPRInAbsoluteValue(
                rewardRate,
                rewardDuration
            );
        return
            ((TDLib.MAX_BPS * accumulatedRewardsIfOneTokenStakedWithPrecision) /
                oneToken) / LSLib.PRECISION;
    }

    function getPrimitives()
        external
        view
        override
        returns (LSLib.Primitives memory)
    {
        return LSLib.get().p;
    }
}
