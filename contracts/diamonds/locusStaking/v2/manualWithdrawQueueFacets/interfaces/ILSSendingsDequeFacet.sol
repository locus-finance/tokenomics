// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

import "../libraries/DelayedSendingsQueueLib.sol";

/// @title A facet that implements CRUD operations on delayed sendings. It also implements queue clearing of those delayed sendings.
/// @author Oleg Bedrin <o.bedrin@locus.finance> - Locus Team
/// @notice The contract is meant to be utilized as a EIP2535 proxy facet. Hence it cannot be called directly and not through
/// the diamond proxy.
interface ILSSendingsDequeFacet {
    /// @notice Creates a delayed sending of any token to any receiver. Could only be called by the diamond itself.
    /// @param sendingToken Token to be sent.
    /// @param receiver A receiver of the sending.
    /// @param amount An amount to be sent.
    /// @param dueToDuration A duration code.
    function addDelayedSending(
        IERC20Metadata sendingToken,
        address receiver,
        uint256 amount,
        DelayedSendingsQueueLib.DueDuration dueToDuration
    ) external;

    /// @notice Cleares the queue. Iterates over every element in the queue, and if the sendings due is now, executes the sending. 
    /// If not, sets it back.
    function processQueue() external;
}
