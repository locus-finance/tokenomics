// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/structs/DoubleEndedQueue.sol";

import "./libraries/WithdrawalsQueueLib.sol";
import "./interfaces/ILSWithdrawDequeFacet.sol";
import "../LSLib.sol";
import "../../facetsFramework/diamondBase/facets/BaseFacet.sol";

contract LSWithdrawDequeFacet is BaseFacet, ILSWithdrawDequeFacet {
    using Counters for Counters.Counter;
    using DoubleEndedQueue for DoubleEndedQueue.Bytes32Deque;

    function addDelayedSending(
        address receiver,
        uint256 amount,
        WithdrawalsQueueLib.DueDuration dueToDuration
    ) external override {}

    function getDelayedSending(uint256 index) external override {}

    function processQueue(
        WithdrawalsQueueLib.DueDuration dueToDuration
    ) external override {}
}
