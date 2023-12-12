// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/structs/DoubleEndedQueue.sol";

// look for the Diamond.sol in the hardhat-deploy/solc_0.8/Diamond.sol
library WithdrawalsQueueLib {
    enum DueDuration {
        NOT_DEFINED,
        ONE_WEEK,
        TWO_WEEKS,
        MONTH
    }

    struct DelayedSending {
        address receiver;
        uint256 amount;
        uint256 dueToTimestamp;
    }

    bytes32 constant LOCUS_STAKING_WITHDRAWALS_STORAGE_POSITION = keccak256("diamond.standard.diamond.storage.locus_staking.withdrawals");

    struct Storage {
        Counters.Counter nodeCounter;
        mapping(uint256 => DelayedSending) queueNodes;
        DoubleEndedQueue.Bytes32Deque sendingsDeque;
    }

    function get() internal pure returns (Storage storage s) {
        bytes32 position = LOCUS_STAKING_WITHDRAWALS_STORAGE_POSITION;
        assembly {
            s.slot := position
        }
    }
}