// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

interface IVEManagementFacet {
    function setLocusToken(address _locusToken) external;

    function setMinLockDuration(uint256 _minLockDuration) external;

    function getLastUserSlope(address addr) external view returns (int128);

    function userPointHistoryTs(
        address addr,
        uint256 idx
    ) external view returns (uint256);
}
