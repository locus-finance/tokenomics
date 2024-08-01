// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "../libraries/DelayedSendingsQueueLib.sol";

/// @title A facet that implements getters and iteration tools over the delayed sendings queue.
/// @author Oleg Bedrin <o.bedrin@locus.finance> - Locus Team
/// @notice The contract is meant to be utilized as a EIP2535 proxy facet. Hence it cannot be called directly and not through
/// the diamond proxy.
interface ILSSendingsDequeLoupeFacet {

    /// @notice Returns a sending struct with full info in the queue.
    /// @param index Required index of the sending in the queue
    /// @return Found sending struct. 
    function getDelayedSending(
        uint256 index
    ) external view returns (DelayedSendingsQueueLib.DelayedSending memory);

    /// @notice Returns size of the sendings queue.
    /// @return The size.
    function getDequeSize() external view returns (uint256);

    /// @notice Returns full array of sendings queue.
    /// @return A deque of sendings. (Or queue of sendings.)
    function getSendingsDeque()
        external
        view
        returns (DelayedSendingsQueueLib.DelayedSending[] memory);

    /// @notice Returns sum of all sendings to be delivered to certain `staker`.
    /// @param staker A staker address to be search info for.
    /// @return A sum of tokens that are going to eventuely go to the `staker`.
    function getTotalSendingsPerStaker(
        address staker
    ) external view returns (uint256);

    /// @notice Returns an array of IDs of the sendings, that are stored in public mapping.
    /// @notice Array on indicies stored in the queue.
    function getSendingsDequeIndiciesStored()
        external
        view
        returns (uint256[] memory);
}
