// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/structs/DoubleEndedQueue.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

// look for the Diamond.sol in the hardhat-deploy/solc_0.8/Diamond.sol
library DelayedSendingsQueueLib {
    error InvalidDueDuration(DueDuration invalidDueDuration);

    enum DueDuration {
        UNDEFINED,
        NOW,
        ONE_WEEK,
        TWO_WEEKS,
        MONTH
    }

    struct DelayedSending {
        address receiver;
        uint256 amount;
        uint256 dueToTimestamp;
        DueDuration dueToDuration;
        IERC20Metadata sendingToken;
    }

    bytes32 constant LOCUS_STAKING_DELAYED_SENDINGS_STORAGE_POSITION = keccak256("diamond.standard.diamond.storage.locus_staking.delayed_sendings");

    bytes32 public constant DELAYED_SENDINGS_QUEUE_PROCESSOR_ROLE = keccak256('DELAYED_SENDINGS_QUEUE_PROCESSOR_ROLE');

    struct Storage {
        Counters.Counter nodeCounter;
        mapping(uint256 => DelayedSending) queueNodes;
        DoubleEndedQueue.Bytes32Deque sendingsDeque;
        mapping(address => uint256) totalSendingsPerStaker;
    }

    function get() internal pure returns (Storage storage s) {
        bytes32 position = LOCUS_STAKING_DELAYED_SENDINGS_STORAGE_POSITION;
        assembly {
            s.slot := position
        }
    }
}