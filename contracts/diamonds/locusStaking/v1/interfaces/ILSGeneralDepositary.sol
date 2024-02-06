// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";

import "../../../notDiamonds/interfaces/IWrappedStakingLocus.sol";

import "../LSLib.sol";
import "../../facetsFramework/diamondBase/facets/BaseFacet.sol";
import "../../facetsFramework/diamondBase/facets/PausabilityFacet.sol";

import "../../locusToken/v1/interfaces/ILTERC20Facet.sol";
import "../../locusToken/v1/autocracy/interfaces/ILTAutocracyFacet.sol";

import "../v2/manualWithdrawQueueFacets/libraries/DelayedSendingsQueueLib.sol";

import "./interfaces/ILSProcessFeesFacet.sol";
import "./interfaces/ILSDepositaryFacet.sol";
import "./interfaces/ILSLoupeFacet.sol";

import "hardhat/console.sol";

abstract contract LSGeneralDepositaryFacet is
    BaseFacet,
    PausabilityFacet,
    ReentrancyGuardUpgradeable,
    ILSDepositaryFacet
{
    using SafeERC20 for IERC20Metadata;

    /// @dev MIND THAT THIS SHOULD BE THE ONLY SMART CONTRACT (MEANING REENTRANCY GUARD) FROM OZ LIB THAT
    /// IS TO BE UTILIZIED IN THIS DIAMOND.
    function _initialize_LSDepositaryFacet()
        external
        override
        initializer
        internalOnly
    {
        __ReentrancyGuard_init();
    }

    function stakeFor(
        address staker,
        uint256 amount
    ) external override nonReentrant delegatedOnly whenNotPaused {
        RolesManagementLib.enforceSenderRole(LSLib.ALLOWED_TO_STAKE_FOR_ROLE);
        _stake(staker, msg.sender, amount);
    }

    function stake(
        uint256 amount
    ) external override nonReentrant delegatedOnly whenNotPaused {
        _stake(msg.sender, msg.sender, amount);
    }

    function withdraw(
        uint256 amount,
        DelayedSendingsQueueLib.DueDuration dueDuration
    ) public;


    function getReward(
        DelayedSendingsQueueLib.DueDuration dueDuration
    ) public override nonReentrant delegatedOnly {
        _getReward(dueDuration);
    }

    function updateReward(address account) public override internalOnly {
        _updateReward(account);
    }

    function _getReward(DelayedSendingsQueueLib.DueDuration dueDuration) internal;

    function _updateReward(address account) internal;

    function _stake(
        address staker,
        address fundsOwner,
        uint256 amount
    ) internal {
        _updateReward(staker);
        LSLib.Primitives storage p = LSLib.get().p;
        IERC20Metadata stakingToken = p.stakingToken;
        if (amount == 0) revert LSLib.CannotStakeZero();
        p.totalSupply += amount;
        LSLib.get().rt.balanceOf[staker] += amount;
        stakingToken.safeTransferFrom(fundsOwner, address(this), amount);
        emit LSLib.Staked(staker, amount);
        if (p.wrappedStLocusToken != address(0) && address(p.stakingToken) == p.locusToken) {
            IWrappedStakingLocus(p.wrappedStLocusToken).syncBalanceOnStake(staker);
        }
    }
}
