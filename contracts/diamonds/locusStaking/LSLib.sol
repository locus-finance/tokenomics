// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

// look for the Diamond.sol in the hardhat-deploy/solc_0.8/Diamond.sol
library LSLib {
    error InvalidBPS(uint16 bps);
    error OnlyRewardsDistribution();
    error CannotStakeZero();
    error CannotWithdrawZero();
    error RewardIsTooHigh(uint256 actualReward);
    error CannotRecoverToken(address token, uint256 amount);
    error ChangingRewardsDurationTooEarly(uint256 deltaInSeconds);
    error NotImplemented();
    error DepositForbidden();

    /// @notice Emits when new rewards amount is added to distribution.
    /// @param reward An amount to be distributed to users.
    event RewardAdded(uint256 indexed reward);

    /// @notice Emits when `user` does stake `amount` of staking tokens.
    /// @param user A staker.
    /// @param amount An amount ot stake.
    event Staked(address indexed user, uint256 indexed amount);

    /// @notice Emits when a delayed sending is executed on due or immedeately.
    /// @param token Token to be sent.
    /// @param user A receiver of the sending.
    /// @param amount An amount to be sent.
    /// @param feesTaken Possible amount of fees to be sent.
    event SentOut(
        address indexed token,
        address indexed user,
        uint256 indexed amount,
        uint256 feesTaken
    );

    /// @notice Emits when staking cycle duration is altered.
    /// @param newDuration New duration of staking cycle in seconds.
    event RewardsDurationUpdated(uint256 indexed newDuration);

    /// @notice Emits when some stucked tokens are retrieved by `OWNER_ROLE` bearer.
    /// @param token Token that was recovered.
    /// @param amount An amount of recovered tokens.
    event Recovered(address indexed token, uint256 indexed amount);

    /// @notice WARNING: NEVER USED ANYWHERE AFTER THE INCIDENT. Emits when a users balance has been restored. 
    /// @param who User whose balance to be restored.
    /// @param index Users index in the queue on restoration.
    event MigrationComplete(address indexed who, uint256 indexed index);

    bytes32 constant LOCUS_STAKING_STORAGE_POSITION =
        keccak256("diamond.standard.diamond.storage.locus_staking");

    /// @dev Classic `AccessControl` role. Allows the bearer to send and distribute rewards.
    bytes32 public constant REWARD_DISTRIBUTOR_ROLE =
        keccak256("REWARD_DISTRIBUTOR_ROLE");

    /// @dev Classic `AccessControl` role. Allows the bearer to stake for users.
    bytes32 public constant ALLOWED_TO_STAKE_FOR_ROLE =
        keccak256("ALLOWED_TO_STAKE_FOR_ROLE");

    /// @notice Precision for math calculations in the diamond.
    uint256 public constant PRECISION = 1 ether;

    /// @dev A container for reference types in the storage.
    struct ReferenceTypes {
        mapping(address => uint256) userRewardPerTokenPaid; // rewards amounts paid per staker
        mapping(address => uint256) rewards; // rewards per user to be paid
        mapping(address => uint256) balanceOf; // deposits per user
    }

    /// @dev A container for primitive types in the storage.
    struct Primitives {
        IERC20Metadata rewardsToken; // token to be utilized as reward token
        IERC20Metadata stakingToken; // token to be utilized as staking token
        uint256 periodFinish; // timestamp when current staking cycle will end
        uint256 rewardRate; // rate with which the rewards are accumulating
        uint256 rewardsDuration; // duration of staking cycle in seconds
        uint256 lastUpdateTime; // last timestamp when the staking cycle has started
        uint256 rewardPerTokenStored; // cumulative paid rewards per 1 token to avoid double paying of rewards
        uint256 totalSupply; // total tokens staked
        uint256 totalReward; // total rewards earned
        address wrappedStLocusToken; // wrapper token to enable EIP20 behaviour for the stakers deposits
        bool areDepositsShut; // flag which blocks deposits (NOT SWITCHABLE CURRENTLY ANYWHERE)
    }

    /// @dev Main storage markdown
    struct Storage {
        Primitives p;
        ReferenceTypes rt;
    }

    /// @dev Returns the storage part that manipulable through Storage struct operations.
    function get() internal pure returns (Storage storage s) {
        bytes32 position = LOCUS_STAKING_STORAGE_POSITION;
        assembly {
            s.slot := position
        }
    }
}
