// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/structs/DoubleEndedQueue.sol";

import "./libraries/DelayedSendingsQueueLib.sol";
import "./interfaces/ILSSendingsDequeFacet.sol";
import "../LSLib.sol";
import "../../facetsFramework/diamondBase/facets/BaseFacet.sol";

contract LSSendingsDequeFacet is BaseFacet, ILSSendingsDequeFacet {
    using Counters for Counters.Counter;
    using DoubleEndedQueue for DoubleEndedQueue.Bytes32Deque;
    using SafeERC20 for IERC20Metadata;

    function addDelayedSending(
        IERC20Metadata sendingToken,
        address receiver,
        uint256 amount,
        DelayedSendingsQueueLib.DueDuration dueToDuration
    ) external override internalOnly {
        DelayedSendingsQueueLib.Storage storage s = DelayedSendingsQueueLib
            .get();
        uint256 currentCounter = s.nodeCounter.current();
        DelayedSendingsQueueLib.DelayedSending storage sending = s.queueNodes[
            currentCounter
        ];
        s.receiver = receiver;
        s.amount = amount;
        s.dueToDuration = dueToDuration;
        s.sendingToken = sendingToken;
        if (dueToDuration == DelayedSendingsQueueLib.DueDuration.ONE_WEEK) {
            s.dueToTimestamp = block.timestamp + 1 weeks;
        } else if (
            dueToDuration == DelayedSendingsQueueLib.DueDuration.TWO_WEEKS
        ) {
            s.dueToTimestamp = block.timestamp + 2 weeks;
        } else if (dueToDuration == DelayedSendingsQueueLib.DueDuration.MONTH) {
            s.dueToTimestamp = block.timestamp + 4 weeks;
        } else {
            revert DelayedSendingsQueueLib.DueDurationUndefined();
        }
        s.sendingsDeque.pushBack(uint256(currentCounter));
        s.nodeCounter.increment();
    }

    function getDelayedSending(
        uint256 index
    )
        external
        view
        override
        returns (DelayedSendingsQueueLib.DelayedSending memory)
    {
        return DelayedSendingsQueueLib.get().queueNodes[index];
    }

    function getDequeSize()
        external
        view
        override
        internalOnly
        returns (uint256)
    {
        return DelayedSendingsQueueLib.get().sendingsDeque.length();
    }

    function processQueue(
        bool isStakingOrRewardTokenUtilized
    ) external override delegatedOnly {
        RolesManagementLib.enforceSenderRole(
            DelayedSendingsQueueLib.DELAYED_SENDINGS_QUEUE_PROCESSOR_ROLE
        );
        DelayedSendingsQueueLib.Storage storage s = DelayedSendingsQueueLib
            .get();
        while (s.sendingsDeque.length() != 0) {
            uint256 delayedSendingIdx = uint256(s.sendingsDeque.popFront());
            DelayedSendingsQueueLib.DelayedSending storage sending = s
                .queueNodes[delayedSendingIdx];
            if (block.timestamp >= sending.dueToTimestamp) {
                s.sendingToken.safeTransfer(sending.receiver, sending.amount);
            }
        }
    }

    function _getAmountWithAccountedFees(
        uint256 amount,
        DelayedSendingsQueueLib.DueDuration dueToDuration
    ) internal view {}
}
