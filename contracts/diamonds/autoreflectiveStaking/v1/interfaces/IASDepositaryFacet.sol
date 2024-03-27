// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "../../../locusStaking/v2/manualWithdrawQueueFacets/libraries/DelayedSendingsQueueLib.sol";

/// @title A facet that implements the depositary logic for users. 
/// @author Oleg Bedrin <o.bedrin@locus.finance> - Locus Team
/// @notice The contract is meant to be utilized as a EIP2535 proxy facet. Hence it cannot be called directly and not through
/// the diamond proxy.
interface IASDepositaryFacet {
    event Staked(uint256 indexed amount);
    event Withdrawn(uint256 indexed amount);
    event RewardAdded(uint256 indexed amount);

    function stake(uint256 amount) external;

    function withdraw(uint256 amount, DelayedSendingsQueueLib.DueDuration dueDuration) external;

    function notifyRewardAmount(uint256 amount) external;
}
