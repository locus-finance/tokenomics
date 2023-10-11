// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "../LSLib.sol";
import "../../diamondBase/facets/BaseFacet.sol";
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
}
