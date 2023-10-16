// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

// look for the Diamond.sol in the hardhat-deploy/solc_0.8/Diamond.sol
library TDLib {
    error InvalidOffset(uint256 offset);
    error IntervalsMustBeSorted();
    error NothingWasFound();
    error IncorrectLengths(uint256 l1, uint256 l2);

    event ReceiverAltered(
        address indexed receiver,
        uint256 indexed share,
        bool indexed isBlocked,
        uint256 sumOfShares
    );
    event Distributed(
        uint256 indexed distributedValue,
        uint256 indexed tokensLeftAndSentToGovernance
    );

    bytes32 constant LOCUS_TOKEN_DISTRIBUTION_STORAGE_POSITION =
        keccak256("diamond.standard.diamond.storage.locus.token_distribution");

    uint16 public constant MAX_BPS = 10000;

    struct DistributionReceiver {
        uint256 share;
        uint256 previousShare;
        address receiver;
        bool isBlocked;
    }

    struct Storage {
        // address (middleman) for which we are counting a fee or a share
        //      => timestamp to which we would add durations from `distributionDurationPoints`.
        mapping(address => uint32) startTimestamps;
        uint32[] distributionDurationPoints;
        mapping(uint256 => mapping(address => uint256)) distributionDurationPointIdxToMiddlemanToAmounts;
        DistributionReceiver[] distributionReceivers;
        uint256 sumOfShares;
        address undistributedAmountsReceiver;
    }

    function get() internal pure returns (Storage storage s) {
        bytes32 position = LOCUS_TOKEN_DISTRIBUTION_STORAGE_POSITION;
        assembly {
            s.slot := position
        }
    }

    function getAmountToDistribute(
        address entity,
        address middleman
    ) internal view returns (uint256 distributionAmounts) {
        uint32 startStakingTime = get().startTimestamps[entity];
        if (block.timestamp > startStakingTime) {
            uint32 timeCounter = startStakingTime;
            uint256 distributionDurationPointsLen = get()
                .distributionDurationPoints
                .length;
            uint256 idx;
            for (idx; idx < distributionDurationPointsLen; idx++) {
                uint32 distributionDurationPoint = get()
                    .distributionDurationPoints[idx];
                if (block.timestamp < timeCounter + distributionDurationPoint) {
                    break;
                } else {
                    timeCounter += distributionDurationPoint;
                }
            }
            distributionAmounts = get()
                .distributionDurationPointIdxToMiddlemanToAmounts[idx][middleman];
        }
    }
}
