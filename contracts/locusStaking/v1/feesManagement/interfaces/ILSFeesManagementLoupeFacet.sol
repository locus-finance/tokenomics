// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import "../libraries/LSFeesLib.sol";

interface ILSFeesManagementLoupeFacet {
    function getFeeReceiversByAddresses(
        uint256 offset,
        uint256 windowSize,
        address[] memory addresses
    ) external view returns (uint256[] memory indicies);

    function getFeeReceiversByShares(
        uint256 offset,
        uint256 windowSize,
        uint256[] memory shares
    ) external view returns (uint256[] memory indicies);

    function getFeeReceiversByStatuses(
        uint256 offset,
        uint256 windowSize,
        bool[] memory statuses
    ) external view returns (uint256[] memory indicies);

    function getFeeReceiverByIdx(
        uint256 idx
    ) external view returns (LSFeesLib.FeeReceiver memory);

    function getSumOfShares() external view returns (uint256);
}
