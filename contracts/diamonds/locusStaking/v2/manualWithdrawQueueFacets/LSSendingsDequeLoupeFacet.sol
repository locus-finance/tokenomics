// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/utils/structs/DoubleEndedQueue.sol";

import "../../../facetsFramework/diamondBase/facets/BaseFacet.sol";
import "../../LSLib.sol";
import "./libraries/DelayedSendingsQueueLib.sol";
import "./interfaces/ILSSendingsDequeLoupeFacet.sol";

/// @title A facet that implements getters and iteration tools over the delayed sendings queue.
/// @author Oleg Bedrin <o.bedrin@locus.finance> - Locus Team
/// @notice The contract is meant to be utilized as a EIP2535 proxy facet. Hence it cannot be called directly and not through
/// the diamond proxy.
contract LSSendingsDequeLoupeFacet is BaseFacet, ILSSendingsDequeLoupeFacet {
    using DoubleEndedQueue for DoubleEndedQueue.Bytes32Deque;

    /// @inheritdoc ILSSendingsDequeLoupeFacet
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

    /// @inheritdoc ILSSendingsDequeLoupeFacet
    function getTotalSendingsPerStaker(
        address staker
    ) external view override returns (uint256) {
        return DelayedSendingsQueueLib.get().totalSendingsPerStaker[staker];
    }

    /// @inheritdoc ILSSendingsDequeLoupeFacet
    function getDequeSize()
        external
        view
        override
        delegatedOnly
        returns (uint256)
    {
        return DelayedSendingsQueueLib.get().sendingsDeque.length();
    }

    /// @inheritdoc ILSSendingsDequeLoupeFacet
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

    /// @inheritdoc ILSSendingsDequeLoupeFacet
    function getSendingsDequeIndiciesStored()
        external
        view
        override
        delegatedOnly
        returns (uint256[] memory result)
    {
        DoubleEndedQueue.Bytes32Deque storage deque = DelayedSendingsQueueLib.get().sendingsDeque;
        uint256 dequeSize = deque.length();
        result = new uint256[](dequeSize);
        for (uint256 i; i < dequeSize; i++) {
            result[i] = uint256(deque.at(i));
        }
    }
}
