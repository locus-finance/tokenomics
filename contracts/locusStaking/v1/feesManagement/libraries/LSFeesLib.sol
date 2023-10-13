// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

// look for the Diamond.sol in the hardhat-deploy/solc_0.8/Diamond.sol
library LSFeesLib {
    error InvalidOffset(uint256 offset);
    error IntervalsMustBeSorted();
    error NothingWasFound();
    error IncorrectLengths(uint256 l1, uint256 l2);
    error InvalidBPS(uint16 bps);

    event FeeReceiverAltered(
        address indexed feeReceiver,
        uint256 indexed share,
        bool indexed isBlocked,
        uint256 sumOfShares
    );
    event FeesDistributed(
        uint256 indexed distributedValue,
        uint256 indexed tokensLeftAndSentToOwner
    );

    bytes32 constant LOCUS_FEES_STORAGE_POSITION =
        keccak256("diamond.standard.diamond.storage.locus_token.fees");

    uint16 public constant MAX_BPS = 10000;

    struct FeeReceiver {
        uint256 share;
        uint256 previousShare;
        address receiver;
        bool isBlocked;
    }

    struct Storage {
        mapping(address => uint32) stakerToStartStakingTimestamp;
        uint32[] feeDurationPoints;
        mapping(uint256 => uint16) feeDurationPointIdxToFeeBasePoints;
        FeeReceiver[] feeReceivers;
        uint256 sumOfShares;
        address undistributedFeesReceiver;
    }

    function get() internal pure returns (Storage storage s) {
        bytes32 position = LOCUS_FEES_STORAGE_POSITION;
        assembly {
            s.slot := position
        }
    }

    function getFee(address staker) internal view returns (uint16 feeBps) {
        uint32 startStakingTime = get().stakerToStartStakingTimestamp[staker];
        if (block.timestamp > startStakingTime) {
            uint32 timeCounter = startStakingTime;
            uint256 feeDurationPointsLen = get().feeDurationPoints.length;
            uint256 idx;
            for (idx; idx < feeDurationPointsLen; idx++) {
                uint32 feeDurationPoint = get().feeDurationPoints[idx];
                if (block.timestamp < timeCounter + feeDurationPoint) {
                    break;
                } else {
                    timeCounter += feeDurationPoint;
                }
            }
            feeBps = get().feeDurationPointIdxToFeeBasePoints[idx];
        }
    }

}
