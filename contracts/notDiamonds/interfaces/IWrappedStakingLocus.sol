// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

/// @title EIP20 wrapper for Synthetix `StakingRewards.sol` deposit, like `locusStaking`.
/// @author Oleg Bedrin <o.bedrin@locus.finance> - Locus Team
interface IWrappedStakingLocus is IERC20Metadata {
    /// @notice Syncs the balance of the wrapper with deposit on stake.
    /// @param who Deposits owner.
    function syncBalanceOnStake(address who) external;

    /// @notice Syncs the balance of the wrapper with deposit on withdrawal.
    /// @param who Deposits owner.
    function syncBalanceOnWithdraw(address who) external;
}
