// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import "../../locusStaking/v2/manualWithdrawQueueFacets/libraries/DelayedSendingsQueueLib.sol";
import "../../locusStaking/v2/manualWithdrawQueueFacets/interfaces/ILSSendingsDequeFacet.sol";

import "../../facetsFramework/diamondBase/facets/BaseFacet.sol";
import "../ASLib.sol";
import "./interfaces/IASReflectionFacet.sol";
import "./interfaces/IASDepositaryFacet.sol";

/// @title A facet that implements the depositary logic for users. 
/// @author Oleg Bedrin <o.bedrin@locus.finance> - Locus Team
/// @notice The contract is meant to be utilized as a EIP2535 proxy facet. Hence it cannot be called directly and not through
/// the diamond proxy.
contract ASDepositaryFacet is IASDepositaryFacet, BaseFacet {
    using SafeERC20 for IERC20Metadata;

    /// @inheritdoc IASDepositaryFacet
    function stake(uint256 amount) external override delegatedOnly {
        IASReflectionFacet(address(this))._mintTo(msg.sender, amount);
        IERC20Metadata(ASLib.get().p.token).safeTransferFrom(
            msg.sender,
            address(this),
            amount
        );
        emit Staked(amount);
    }

    /// @inheritdoc IASDepositaryFacet
    function withdraw(
        uint256 amount,
        DelayedSendingsQueueLib.DueDuration dueDuration    
    ) external override delegatedOnly {
        IASReflectionFacet(address(this))._burnFrom(msg.sender, amount);
        ILSSendingsDequeFacet(address(this)).addDelayedSending(
            IERC20Metadata(ASLib.get().p.token), msg.sender, amount, dueDuration
        );
        emit Withdrawn(amount);
    }

    /// @inheritdoc IASDepositaryFacet
    function notifyRewardAmount(
        uint256 amount
    ) external override delegatedOnly {
        RolesManagementLib.enforceSenderRole(ASLib.REWARD_DISTRIBUTOR_ROLE);
        ASLib.Primitives storage p = ASLib.get().p;
        IERC20Metadata(p.token).safeTransferFrom(
            msg.sender,
            address(this),
            amount
        );
        p.totalStaked += amount; // because it immedeately distributed.
        p.tTotal += amount;
        IASReflectionFacet(address(this))._updateTotalReflection();
        emit RewardAdded(amount);
    }
}
