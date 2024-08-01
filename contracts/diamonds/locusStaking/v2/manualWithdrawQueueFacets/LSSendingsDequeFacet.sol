// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/structs/DoubleEndedQueue.sol";

import "../../../facetsFramework/tokensDistributor/TDLib.sol";
import "../../../facetsFramework/tokensDistributor/v1/interfaces/ITDProcessFacet.sol";
import "../../../facetsFramework/diamondBase/facets/BaseFacet.sol";
import "../../LSLib.sol";
import "./libraries/DelayedSendingsQueueLib.sol";
import "./interfaces/ILSSendingsDequeFacet.sol";

/// @title A facet that implements CRUD operations on delayed sendings. It also implements queue clearing of those delayed sendings.
/// @author Oleg Bedrin <o.bedrin@locus.finance> - Locus Team
/// @notice The contract is meant to be utilized as a EIP2535 proxy facet. Hence it cannot be called directly and not through
/// the diamond proxy.
contract LSSendingsDequeFacet is BaseFacet, ILSSendingsDequeFacet {
    using Counters for Counters.Counter;
    using DoubleEndedQueue for DoubleEndedQueue.Bytes32Deque;
    using SafeERC20 for IERC20Metadata;

    /// @inheritdoc ILSSendingsDequeFacet
    function addDelayedSending(
        IERC20Metadata sendingToken,
        address receiver,
        uint256 amount,
        DelayedSendingsQueueLib.DueDuration dueToDuration
    ) external override internalOnly {
        DelayedSendingsQueueLib.Storage storage s = DelayedSendingsQueueLib
            .get();
        if (dueToDuration == DelayedSendingsQueueLib.DueDuration.NOW) {
            (
                uint256 amountWithFees,
                uint256 feesGathered
            ) = _getAmountWithAccountedFees(
                    sendingToken,
                    amount,
                    dueToDuration
                );
        
            sendingToken.safeTransfer(receiver, amountWithFees);
            emit LSLib.SentOut(
                address(sendingToken),
                receiver,
                amount,
                feesGathered
            );
            return;
        }

        uint256 currentCounter = s.nodeCounter.current();
        DelayedSendingsQueueLib.DelayedSending storage sending = s.queueNodes[
            currentCounter
        ];
        sending.receiver = receiver;
        sending.amount = amount;
        s.totalSendingsPerStaker[receiver] += amount;
        sending.dueToDuration = dueToDuration;
        sending.sendingToken = sendingToken;

        if (dueToDuration == DelayedSendingsQueueLib.DueDuration.ONE_WEEK) {
            sending.dueToTimestamp = block.timestamp + 1 weeks;
        } else if (
            dueToDuration == DelayedSendingsQueueLib.DueDuration.TWO_WEEKS
        ) {
            sending.dueToTimestamp = block.timestamp + 2 weeks;
        } else if (dueToDuration == DelayedSendingsQueueLib.DueDuration.MONTH) {
            sending.dueToTimestamp = block.timestamp + 4 weeks;
        } else {
            revert DelayedSendingsQueueLib.InvalidDueDuration(dueToDuration);
        }
        s.sendingsDeque.pushBack(bytes32(currentCounter));
        s.nodeCounter.increment();
    }

    /// @inheritdoc ILSSendingsDequeFacet
    function processQueue() external override delegatedOnly {
        RolesManagementLib.enforceSenderRole(
            DelayedSendingsQueueLib.DELAYED_SENDINGS_QUEUE_PROCESSOR_ROLE
        );
        DelayedSendingsQueueLib.Storage storage s = DelayedSendingsQueueLib
            .get();

        uint256 sendingsDequeLen = s.sendingsDeque.length();
        for (uint256 i; i < sendingsDequeLen; i++) {
            uint256 delayedSendingIdx = uint256(s.sendingsDeque.popFront());
            DelayedSendingsQueueLib.DelayedSending storage sending = s
                .queueNodes[delayedSendingIdx];
            if (block.timestamp >= sending.dueToTimestamp) {
                (
                    uint256 amountWithFees,
                    uint256 feesGathered
                ) = _getAmountWithAccountedFees(
                        sending.sendingToken,
                        sending.amount,
                        sending.dueToDuration
                    );
                s.totalSendingsPerStaker[sending.receiver] -= sending.amount;
                sending.sendingToken.safeTransfer(
                    sending.receiver,
                    amountWithFees
                );
                emit LSLib.SentOut(
                    address(sending.sendingToken),
                    sending.receiver,
                    sending.amount,
                    feesGathered
                );
            } else {
                s.sendingsDeque.pushBack(bytes32(delayedSendingIdx));
            }
        }
    }

    /// @dev Mapping function to match due duration code to actual time interval.
    /// @param sendingToken Token of sending.
    /// @param amount An amount of sending.
    /// @param dueToDuration Due duration code of sending.
    /// @return amountWithFees An amount with possible fees to be sent at the moment of the execution.
    /// @return feesGathered An amount of fees that could be possibly charged.
    function _getAmountWithAccountedFees(
        IERC20Metadata sendingToken,
        uint256 amount,
        DelayedSendingsQueueLib.DueDuration dueToDuration
    ) internal returns (uint256 amountWithFees, uint256 feesGathered) {
        uint256 basePoints;
        if (dueToDuration == DelayedSendingsQueueLib.DueDuration.ONE_WEEK) {
            basePoints = 3750;
        } else if (
            dueToDuration == DelayedSendingsQueueLib.DueDuration.TWO_WEEKS
        ) {
            basePoints = 2500;
        } else if (dueToDuration == DelayedSendingsQueueLib.DueDuration.MONTH) {
            // COULD CHANGE IN THE FUTURE
            basePoints = 0;
        } else if (dueToDuration == DelayedSendingsQueueLib.DueDuration.NOW) {
            basePoints = 5000;
        } else {
            revert DelayedSendingsQueueLib.InvalidDueDuration(dueToDuration);
        }

        feesGathered = (amount * basePoints) / TDLib.MAX_BPS;
        amountWithFees = amount - feesGathered;

        if (feesGathered > 0) {
            ITDProcessFacet(address(this)).distribute(
                feesGathered,
                sendingToken
            );
        }
    }
}
