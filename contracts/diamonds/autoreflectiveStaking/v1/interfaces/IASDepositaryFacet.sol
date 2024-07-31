// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "../../../locusStaking/v2/manualWithdrawQueueFacets/libraries/DelayedSendingsQueueLib.sol";

/// @title A facet that implements the depositary logic for users. 
/// @author Oleg Bedrin <o.bedrin@locus.finance> - Locus Team
/// @notice The contract is meant to be utilized as a EIP2535 proxy facet. Hence it cannot be called directly and not through
/// the diamond proxy.
interface IASDepositaryFacet {
    
    /// Emits when staking operation has completed successfully.
    /// @param amount An amount of staking token staked.
    event Staked(uint256 indexed amount);

    /// Emits when withdrawal operation has completed successfully.
    /// @param amount An amount of staking token withdrawn.
    event Withdrawn(uint256 indexed amount);

    /// Emits when reward tokens are added to the distribution to users.
    /// @param amount An amount of reward tokens to be distributed to users.
    event RewardAdded(uint256 indexed amount);

    /// @notice Stakes a number of staking tokens.
    /// @dev Triggers `event Staked(...)`.
    /// @param amount An amount of staking token to be staked.
    function stake(uint256 amount) external;

    /// @notice Withdraws a number of staking tokens.
    /// @dev Triggers `event Withdrawn(...)`.
    /// @param amount An amount of staking token to be withdrawn.
    /// @param dueDuration Code of time interval after which the tokens would be sent to the `msg.sender`.
    function withdraw(uint256 amount, DelayedSendingsQueueLib.DueDuration dueDuration) external;

    /// @notice Sends from `msg.sender` reward tokens to be distributed among users.
    /// @dev Triggers `event RewardAdded(...)`.
    /// @param amount An amount of reward tokens to be distributed.
    function notifyRewardAmount(uint256 amount) external;
}
