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

    event RewardAdded(uint256 indexed reward);
    event Staked(address indexed user, uint256 indexed amount);
    event Withdrawn(address indexed user, uint256 indexed amount, uint256 indexed feesTaken);
    event RewardPaid(address indexed user, uint256 indexed reward, uint256 indexed feesTaken);
    event RewardsDurationUpdated(uint256 indexed newDuration);
    event Recovered(address indexed token, uint256 indexed amount);

    bytes32 constant LOCUS_STAKING_STORAGE_POSITION = keccak256("diamond.standard.diamond.storage.locus_staking");

    bytes32 public constant REWARD_DISTRIBUTOR_ROLE = keccak256('REWARD_DISTRIBUTOR_ROLE');
    bytes32 public constant ALLOWED_TO_STAKE_FOR_ROLE = keccak256('ALLOWED_TO_STAKE_FOR_ROLE');

    uint256 public constant PRECISION = 1 ether;

    struct ReferenceTypes {
        mapping(address => uint256) userRewardPerTokenPaid;
        mapping(address => uint256) rewards;
        mapping(address => uint256) balanceOf;
    }

    struct Primitives {
        IERC20Metadata rewardsToken;
        IERC20Metadata stakingToken;
        address locusToken;
        uint256 periodFinish;
        uint256 rewardRate;
        uint256 rewardsDuration;
        uint256 lastUpdateTime;
        uint256 rewardPerTokenStored;
        uint256 totalSupply;
        uint256 totalReward;
    }

    struct Storage {
        Primitives p;
        ReferenceTypes rt;
    }

    function get() internal pure returns (Storage storage s) {
        bytes32 position = LOCUS_STAKING_STORAGE_POSITION;
        assembly {
            s.slot := position
        }
    }
}