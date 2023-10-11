// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

// look for the Diamond.sol in the hardhat-deploy/solc_0.8/Diamond.sol
library VELib {
    error MaxTimeHit();
    error CannotLockZero();
    error CannotAddToLockWithZeroBalance();
    error LockHasNotYetBeenCreated();
    error LockExpired();
    error CannotCreateLockInPastTime();
    error CannotCreateLockForLessThenMinLock();
    error CanOnlyModifyLockDuration();
    error LockHasToBeExpired();
    error CanOnlyLookIntoPastBlocks();

    event Deposit(
        address indexed provider,
        uint256 value,
        uint256 indexed locktime,
        int128 _type,
        uint256 ts
    );
    event Withdraw(address indexed provider, uint256 value, uint256 ts);
    event Supply(uint256 prevSupply, uint256 supply);

    struct Point {
        int128 bias;
        int128 slope; // - dweight / dt
        uint256 ts;
        uint256 blk; // block
    }

    struct LockedBalance {
        int128 amount;
        uint256 end;
        uint256 start;
    }

    struct ReferenceTypes {
        mapping(address => LockedBalance) locked;
        mapping(uint256 => Point) pointHistory; // epoch -> unsigned point /*Point[100000000000000000000000000000]*/
        // Point[1000000000]
        mapping(address => mapping(uint256 => Point)) userPointHistory; // user -> Point[user_epoch]
        mapping(address => uint256) userPointEpoch;
        mapping(uint256 => int128) slopeChanges; // time -> signed slope change
    }

    struct Primitives {
        uint256 supply;
        uint256 epoch;
        uint256 minLockDuration;
        address locusToken;
    }

    struct Storage {
        Primitives p;
        ReferenceTypes rt;
    }

    bytes32 constant VOTING_ESCROW_STORAGE_POSITION = keccak256("diamond.standard.diamond.storage.voting_escrow");

    int128 public constant DEPOSIT_FOR_TYPE = 0;
    int128 public constant CREATE_LOCK_TYPE = 1;
    int128 public constant INCREASE_LOCK_AMOUNT = 2;
    int128 public constant INCREASE_UNLOCK_TIME = 3;

    // General constants
    uint256 public constant YEAR = 4 weeks * 12;
    uint256 public constant MAXTIME = YEAR * 2;
    uint256 public constant MULTIPLIER = 10 ether;

    uint8 public constant decimals = 18;
    string public constant name = "Voting Escrow Locus Token";
    string public constant symbol = "veLCS";

    function binarySearch(
        uint256 _block,
        uint256 maxBlock,
        bytes memory metainfo,
        function(uint256, bytes memory) view returns (uint256) getBlockFrom
    ) internal view returns (uint256) {
        uint256 _min = 0;
        uint256 _max = maxBlock;
        for (uint256 i = 0; i < 128; i++) {
            if (_min >= _max) {
                break;
            }
            uint256 _mid = (_min + _max + 1) / 2;
            if (getBlockFrom(_mid, metainfo) <= _block) {
                _min = _mid;
            } else {
                _max = _mid - 1;
            }
        }
        return _min;
    }

    function get() internal pure returns (Storage storage s) {
        bytes32 position = VOTING_ESCROW_STORAGE_POSITION;
        assembly {
            s.slot := position
        }
    }
}