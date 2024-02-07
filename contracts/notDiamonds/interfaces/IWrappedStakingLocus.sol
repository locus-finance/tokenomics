// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

interface IWrappedStakingLocus is IERC20Metadata {
    function syncBalanceOnStake(address who) external;

    function syncBalanceOnWithdraw(address who) external;
}
