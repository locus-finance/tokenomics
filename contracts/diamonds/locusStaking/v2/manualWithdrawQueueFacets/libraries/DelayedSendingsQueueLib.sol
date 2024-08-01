// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/structs/DoubleEndedQueue.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

// look for the Diamond.sol in the hardhat-deploy/solc_0.8/Diamond.sol
library DelayedSendingsQueueLib {
    error InvalidDueDuration(DueDuration invalidDueDuration);

    /// @dev Possible "due duraion" codes.
    enum DueDuration {
        UNDEFINED, // Default value, should fire `error InvalidDueDuration(...)`.
        NOW, // Sending has to be executed now and is not to be stored in the deque.
        ONE_WEEK, // Sending has to be executed in one week. 
        TWO_WEEKS, // Sending has to be executed in two weeks.
        MONTH // Sending has to be executed in a month.
    }

    /// @dev Delayed sending struct.
    struct DelayedSending {
        address receiver; // Receiver of the sendings funds.
        uint256 amount; // An amount to be received by the receiver.
        uint256 dueToTimestamp; // Timestamp when the sending should be executed.
        DueDuration dueToDuration; // Due duration code.
        IERC20Metadata sendingToken; // Token of the sending (that should be delivered).
    }

    /// @dev Slot number when the storage has been markdowned.
    bytes32 constant LOCUS_STAKING_DELAYED_SENDINGS_STORAGE_POSITION = keccak256("diamond.standard.diamond.storage.locus_staking.delayed_sendings");

    /// @dev Classic `AccessControl` role. Allowes the bearer to clear the deque of sendings.
    bytes32 public constant DELAYED_SENDINGS_QUEUE_PROCESSOR_ROLE = keccak256('DELAYED_SENDINGS_QUEUE_PROCESSOR_ROLE');

    /// @dev Main storage markdown
    struct Storage {
        Counters.Counter nodeCounter;
        mapping(uint256 => DelayedSending) queueNodes;
        DoubleEndedQueue.Bytes32Deque sendingsDeque;
        mapping(address => uint256) totalSendingsPerStaker;
    }

    /// @dev Returns the storage part that manipulable through Storage struct operations.
    function get() internal pure returns (Storage storage s) {
        bytes32 position = LOCUS_STAKING_DELAYED_SENDINGS_STORAGE_POSITION;
        assembly {
            s.slot := position
        }
    }
}