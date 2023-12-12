// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "../libraries/WithdrawalsQueueLib.sol";

interface ILSWithdrawDequeFacet {
    function addDelayedSending(
        address receiver,
        uint256 amount,
        WithdrawalsQueueLib.DueDuration dueToDuration
    ) external;

    function getDelayedSending(uint256 index) external;

    function processQueue(WithdrawalsQueueLib.DueDuration dueToDuration) external;
}
