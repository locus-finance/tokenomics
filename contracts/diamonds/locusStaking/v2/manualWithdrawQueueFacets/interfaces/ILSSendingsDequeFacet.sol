// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

import "../libraries/DelayedSendingsQueueLib.sol";

interface ILSSendingsDequeFacet {
    function addDelayedSending(
        IERC20Metadata sendingToken,
        address receiver,
        uint256 amount,
        DelayedSendingsQueueLib.DueDuration dueToDuration
    ) external;

    function processQueue() external;
}
