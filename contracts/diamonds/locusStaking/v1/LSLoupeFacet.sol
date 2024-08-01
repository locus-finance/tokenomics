// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

import "../LSLib.sol";
import "../../facetsFramework/diamondBase/facets/BaseFacet.sol";
import "../../facetsFramework/tokensDistributor/TDLib.sol";
import "./interfaces/ILSLoupeFacet.sol";

/// @title A facet that implements view functions of the diamond.
/// @author Oleg Bedrin <o.bedrin@locus.finance> - Locus Team
/// @notice The contract is meant to be utilized as a EIP2535 proxy facet. Hence it cannot be called directly and not through
/// the diamond proxy.
contract LSLoupeFacet is BaseFacet, ILSLoupeFacet {
    /// @inheritdoc ILSLoupeFacet
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

    /// @inheritdoc ILSLoupeFacet
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

    /// @inheritdoc ILSLoupeFacet
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

    /// @inheritdoc ILSLoupeFacet
    function getTotalReward()
        external
        view
        override
        delegatedOnly
        returns (uint256)
    {
        return LSLib.get().p.totalReward;
    }

    /// @inheritdoc ILSLoupeFacet
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

    /// @inheritdoc ILSLoupeFacet
    function totalSupply() external view override delegatedOnly returns (uint256) {
        return LSLib.get().p.totalSupply;
    }

    /// @inheritdoc ILSLoupeFacet
    function balanceOf(
        address account
    ) external view override delegatedOnly returns (uint256) {
        return LSLib.get().rt.balanceOf[account];
    }

    /// @inheritdoc ILSLoupeFacet
    function decimals() external view override delegatedOnly returns (uint8) {
        return LSLib.get().p.stakingToken.decimals();
    }

    /// @inheritdoc ILSLoupeFacet
    function getProjectedAPR(
        uint256 rewardRate,
        uint256 rewardDuration
    ) external view override delegatedOnly returns (uint256) {
        return _getProjectedAPR(rewardRate, rewardDuration);
    }

    /// @inheritdoc ILSLoupeFacet
    function getAPR() external view override delegatedOnly returns (uint256) {
        LSLib.Primitives memory p = LSLib.get().p;
        return _getProjectedAPR(p.rewardRate, p.rewardsDuration);
    }

    /// @inheritdoc ILSLoupeFacet
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

    /// @dev Calculates projected rewards if 1 token would be staking for 1 staking cycle.
    /// @param rewardRate A rate with which rewards are accumulated.
    /// @param rewardDuration  A staking cycle duration.
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

    /// @dev Calculates projected APR (where annual equal to 1 staking cycle).
    /// @param rewardRate A rate with which rewards are accumulated.
    /// @param rewardDuration  A staking cycle duration.
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

    /// @inheritdoc ILSLoupeFacet
    function getPrimitives()
        external
        view
        override
        returns (LSLib.Primitives memory)
    {
        return LSLib.get().p;
    }
}
