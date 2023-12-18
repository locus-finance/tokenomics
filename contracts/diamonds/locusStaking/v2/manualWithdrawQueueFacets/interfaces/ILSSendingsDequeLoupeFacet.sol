// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "../libraries/DelayedSendingsQueueLib.sol";

interface ILSSendingsDequeLoupeFacet {
    function getDelayedSending(
        uint256 index
    ) external view returns (DelayedSendingsQueueLib.DelayedSending memory);

    function getDequeSize() external view returns (uint256);

    function getSendingsDeque()
        external
        view
        returns (DelayedSendingsQueueLib.DelayedSending[] memory);

    function getTotalSendingsPerStaker(
        address staker
    ) external view returns (uint256);
}
