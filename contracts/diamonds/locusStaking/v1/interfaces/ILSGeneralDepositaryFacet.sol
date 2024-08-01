// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";

import "../../../../notDiamonds/interfaces/IWrappedStakingLocus.sol";

import "../../LSLib.sol";

import "../../../facetsFramework/diamondBase/facets/BaseFacet.sol";
import "../../../facetsFramework/diamondBase/facets/PausabilityFacet.sol";

import "../../v2/manualWithdrawQueueFacets/libraries/DelayedSendingsQueueLib.sol";

import "./ILSProcessFeesFacet.sol";
import "./ILSDepositaryFacet.sol";
import "./ILSLoupeFacet.sol";

/// @title A facet that implements the basic depositary logic for users, specifically: `stakeFor`, `stake`, `getReward`, `updateReward`.
/// @author Oleg Bedrin <o.bedrin@locus.finance> - Locus Team
/// @notice The contract is meant to be utilized as a EIP2535 proxy facet. Hence it cannot be called directly and not through
/// the diamond proxy.
abstract contract ILSGeneralDepositaryFacet is
    BaseFacet,
    PausabilityFacet,
    ReentrancyGuardUpgradeable,
    ILSDepositaryFacet
{
    using SafeERC20 for IERC20Metadata;

    /// @inheritdoc ILSDepositaryFacet
    function _initialize_LSDepositaryFacet()
        external
        override
        initializer
        internalOnly
    {
        __ReentrancyGuard_init();
    }

    /// @inheritdoc ILSDepositaryFacet
    function stakeFor(
        address staker,
        uint256 amount
    ) external override nonReentrant delegatedOnly whenNotPaused {
        RolesManagementLib.enforceSenderRole(LSLib.ALLOWED_TO_STAKE_FOR_ROLE);
        _stake(staker, msg.sender, amount);
    }

    /// @inheritdoc ILSDepositaryFacet
    function stake(
        uint256 amount
    ) external override nonReentrant delegatedOnly whenNotPaused {
        _stake(msg.sender, msg.sender, amount);
    }

    /// @inheritdoc ILSDepositaryFacet
    function getReward(
        DelayedSendingsQueueLib.DueDuration dueDuration
    ) public override nonReentrant delegatedOnly {
        _getReward(dueDuration);
    }

    /// @inheritdoc ILSDepositaryFacet
    function updateReward(address account) public override internalOnly {
        _updateReward(account);
    }

    /// @dev Standard realization of `getReward` from Synthetix' `StakingRewards.sol` but instead of
    /// `safeTransfer` immideately - sends it with delay through `ILSProcessFeesFacet` facet.
    /// @param dueDuration A code of time duration interval to expect earned funds after.
    function _getReward(
        DelayedSendingsQueueLib.DueDuration dueDuration
    ) internal {
        _updateReward(msg.sender);
        LSLib.Primitives storage p = LSLib.get().p;
        LSLib.ReferenceTypes storage rt = LSLib.get().rt;
        uint256 reward = rt.rewards[msg.sender];
        if (reward > 0) {
            rt.rewards[msg.sender] = 0;
            p.totalReward -= reward;
            ILSProcessFeesFacet(address(this)).processRewardSending(
                msg.sender,
                reward,
                dueDuration
            );
        }
    }

    /// @dev Classic Synthetix' `StakingRewards.sol` `updateReward` implementation but
    /// for EIP2535 facet.
    /// @param account An account to update rewards info for.
    function _updateReward(address account) internal {
        ILSLoupeFacet self = ILSLoupeFacet(address(this));
        LSLib.Primitives storage p = LSLib.get().p;
        LSLib.ReferenceTypes storage rt = LSLib.get().rt;
        p.rewardPerTokenStored = self.rewardPerToken();
        p.lastUpdateTime = self.lastTimeRewardApplicable();
        if (account != address(0)) {
            rt.rewards[account] = self.earned(account);
            rt.userRewardPerTokenPaid[account] = p.rewardPerTokenStored;
        }
    }

    /// @dev Performs unchecked stake operation with rewards math update.
    /// @param staker A staker.
    /// @param fundsOwner Actual funds owner to stake for `staker`.
    /// @param amount An amount of funds to stake.
    function _stake(
        address staker,
        address fundsOwner,
        uint256 amount
    ) internal virtual;

    /// @inheritdoc ILSDepositaryFacet
    function withdraw(
        uint256 amount,
        DelayedSendingsQueueLib.DueDuration dueDuration
    ) public virtual;
}
