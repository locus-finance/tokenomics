// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import "../../LSLib.sol";
import "../../v2/manualWithdrawQueueFacets/interfaces/ILSSendingsDequeFacet.sol";
import "../../v2/manualWithdrawQueueFacets/libraries/DelayedSendingsQueueLib.sol";
import "../../../facetsFramework/diamondBase/facets/BaseFacet.sol";
import "../interfaces/ILSProcessFeesFacet.sol";

/// @title A facet that implements creation of delayed sendings for vault tokens. 
/// @author Oleg Bedrin <o.bedrin@locus.finance> - Locus Team
/// @notice The contract is meant to be utilized as a EIP2535 proxy facet. Hence it cannot be called directly and not through
/// the diamond proxy.
contract LSProcessFeesForVaultTokensFacet is BaseFacet, ILSProcessFeesFacet {
    using SafeERC20 for IERC20Metadata;

    /// @inheritdoc ILSProcessFeesFacet
    function processRewardSending(
        address staker,
        uint256 reward,
        DelayedSendingsQueueLib.DueDuration dueDuration
    ) external override internalOnly {
        LSLib.Primitives storage p = LSLib.get().p;
        ILSSendingsDequeFacet(address(this)).addDelayedSending(
            p.rewardsToken, staker, reward, dueDuration
        );
    }

    /// @inheritdoc ILSProcessFeesFacet
    function processWithdrawalSending(
        address staker,
        uint256 amount,
        DelayedSendingsQueueLib.DueDuration
    ) external override internalOnly {
        LSLib.Primitives storage p = LSLib.get().p;
        p.stakingToken.safeTransfer(staker, amount);
        emit LSLib.SentOut(address(p.stakingToken), staker, amount, 0);
    }
}
