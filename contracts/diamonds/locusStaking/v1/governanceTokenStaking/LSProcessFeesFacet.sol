// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import "../../LSLib.sol";
import "../../v2/manualWithdrawQueueFacets/interfaces/ILSSendingsDequeFacet.sol";
import "../../v2/manualWithdrawQueueFacets/libraries/DelayedSendingsQueueLib.sol";
import "../../../facetsFramework/diamondBase/facets/BaseFacet.sol";
import "../interfaces/ILSProcessFeesFacet.sol";

contract LSProcessFeesFacet is BaseFacet, ILSProcessFeesFacet {
    using SafeERC20 for IERC20Metadata;

    function processRewardSending(
        address staker,
        uint256 reward,
        DelayedSendingsQueueLib.DueDuration
    ) external override internalOnly {
        LSLib.Primitives storage p = LSLib.get().p;
        p.rewardsToken.safeTransfer(staker, reward);
        emit LSLib.SentOut(address(p.rewardsToken), staker, reward, 0);
    }

    function processWithdrawalSending(
        address staker,
        uint256 amount,
        DelayedSendingsQueueLib.DueDuration dueDuration
    ) external override internalOnly {
        LSLib.Primitives storage p = LSLib.get().p;
        ILSSendingsDequeFacet(address(this)).addDelayedSending(
            p.stakingToken, staker, amount, dueDuration
        );
    }
}
