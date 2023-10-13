// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "../LSLib.sol";
import "../../diamondBase/facets/BaseFacet.sol";
import "./interfaces/ILSInitializerFacet.sol";
import "./interfaces/ILSDepositaryFacet.sol";

contract LSInitializerFacet is BaseFacet, ILSInitializerFacet {
    function initialize(
        address owner,
        address votingEscrow,
        address rewardDistributor,
        address rewardsToken,
        address stakingToken
    ) external override delegatedOnly {
        InitializerLib.initialize();
        ILSDepositaryFacet(address(this))._initialize_LSDepositaryFacet();
        RolesManagementLib.grantRole(rewardDistributor, LSLib.REWARD_DISTRIBUTOR_ROLE);
        RolesManagementLib.grantRole(owner, RolesManagementLib.OWNER_ROLE);
        LSLib.Primitives storage p = LSLib.get().p;
        p.rewardsToken = IERC20(rewardsToken);
        p.stakingToken = IERC20(stakingToken);
        p.votingEscrow = votingEscrow;
        p.rewardsDuration = 1 days;
        p.autoLockDuration = 30 days;
    }
}