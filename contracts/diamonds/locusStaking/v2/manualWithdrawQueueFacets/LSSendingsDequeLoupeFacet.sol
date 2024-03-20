// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/utils/structs/DoubleEndedQueue.sol";

import "../../../facetsFramework/diamondBase/facets/BaseFacet.sol";
import "../../LSLib.sol";
import "./libraries/DelayedSendingsQueueLib.sol";
import "./interfaces/ILSSendingsDequeLoupeFacet.sol";

contract LSSendingsDequeLoupeFacet is BaseFacet, ILSSendingsDequeLoupeFacet {
    using DoubleEndedQueue for DoubleEndedQueue.Bytes32Deque;

    function getDelayedSending(
        uint256 index
    )
        external
        view
        override
        delegatedOnly
        returns (DelayedSendingsQueueLib.DelayedSending memory)
    {
        return DelayedSendingsQueueLib.get().queueNodes[index];
    }

    function getTotalSendingsPerStaker(
        address staker
    ) external view override returns (uint256) {
        return DelayedSendingsQueueLib.get().totalSendingsPerStaker[staker];
    }

    function getDequeSize()
        external
        view
        override
        delegatedOnly
        returns (uint256)
    {
        return DelayedSendingsQueueLib.get().sendingsDeque.length();
    }

    function getSendingsDeque()
        external
        view
        override
        delegatedOnly
        returns (DelayedSendingsQueueLib.DelayedSending[] memory result)
    {
        DoubleEndedQueue.Bytes32Deque storage deque = DelayedSendingsQueueLib.get().sendingsDeque;
        uint256 dequeSize = deque.length();
        result = new DelayedSendingsQueueLib.DelayedSending[](dequeSize);
        for (uint256 i; i < dequeSize; i++) {
            result[i] = ILSSendingsDequeLoupeFacet(address(this))
                .getDelayedSending(uint256(deque.at(i)));
        }
    }
}
