// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

interface IVEInitializerFacet {
    function initialize(uint256 minLockDuration, address locusToken) external; 
}