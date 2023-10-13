// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

interface ILGCheckpointFacet {
    function userCheckpoint(address user) external;
    function integrateFraction(address user) external view returns(uint256 totalMintForUser);
}
