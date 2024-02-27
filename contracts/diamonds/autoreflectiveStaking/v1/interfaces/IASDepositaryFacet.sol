// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

interface IASDepositaryFacet {
    function stake(uint256 amount) external;
    function withdraw(uint256 amount) external;
    function notifyRewardAmount(uint256 amount) external;
}
