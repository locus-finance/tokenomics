// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

// look for the Diamond.sol in the hardhat-deploy/solc_0.8/Diamond.sol
library TDLib {
    error InvalidOffset(uint256 offset);
    error IntervalsMustBeSorted();
    error NothingWasFound();
    error IncorrectLengths(uint256 l1, uint256 l2);

    /// @notice Emits when tokens receiver info is altered.
    /// @param receiver A tokens receiver.
    /// @param share The receivers share.
    /// @param isBlocked The receivers status.
    /// @param sumOfShares Total sum of all shares.
    event ReceiverAltered(
        address indexed receiver,
        uint256 indexed share,
        bool indexed isBlocked,
        uint256 sumOfShares
    );

    /// @notice Emits when tokens distribution is triggered.
    /// @param distributedValue An amount of tokens distributed.
    /// @param tokensLeftAndSentToGovernance A dust that could be left after all divisions. It is sent to the governance or distribution
    /// call sender.
    event Distributed(
        uint256 indexed distributedValue,
        uint256 indexed tokensLeftAndSentToGovernance
    );

    /// @dev Slot number when the storage has been markdowned.
    bytes32 constant LOCUS_TOKEN_DISTRIBUTION_STORAGE_POSITION =
        keccak256("diamond.standard.diamond.storage.locus.token_distribution");

    uint16 public constant MAX_BPS = 10000;

    /// @dev Tokens receiver info.
    struct DistributionReceiver {
        uint256 share;
        uint256 previousShare;
        address receiver;
        bool isBlocked;
    }

    /// @dev Main storage markdown
    struct Storage {
        mapping(address => uint32) startTimestamps;
        uint32[] distributionDurationPoints;
        mapping(uint256 => uint256) distributionDurationPointIdxToAmounts;
        DistributionReceiver[] distributionReceivers;
        uint256 sumOfShares;
        address undistributedAmountsReceiver;
    }

    /// @dev Returns the storage part that manipulable through Storage struct operations.
    function get() internal pure returns (Storage storage s) {
        bytes32 position = LOCUS_TOKEN_DISTRIBUTION_STORAGE_POSITION;
        assembly {
            s.slot := position
        }
    }

    /// @dev DEPRECATED AND NOT USED ANYWHERE. Calculates how much from total value stored in the diamond
    /// should be distributed among the token receivers depending on relative time from duration points 
    /// (basically timestamps after which the sum should be different).
    function getAmountToDistribute(
        address entity
    )
        internal
        view
        returns (
            uint256 distributionAmount,
            uint256 distributionDurationPointIdx
        )
    {
        uint32 startStakingTime = get().startTimestamps[entity];
        if (block.timestamp >= startStakingTime) {
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
            distributionAmount = get().distributionDurationPointIdxToAmounts[
                idx
            ];
            distributionDurationPointIdx = idx;
        }
    }
}
