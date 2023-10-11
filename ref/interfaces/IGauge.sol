// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

interface IGauge {
    function integrateFraction(address addr) external view returns (uint256);
    function userCheckpoint(address user) external returns (bool);
}