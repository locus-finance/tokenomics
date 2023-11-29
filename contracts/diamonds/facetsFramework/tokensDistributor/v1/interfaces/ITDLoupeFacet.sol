// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "../../TDLib.sol";

interface ITDLoupeFacet {
    function getReceiversByAddresses(
        uint256 offset,
        uint256 windowSize,
        address[] memory addresses
    ) external view returns (uint256[] memory indicies);

    function getReceiversByShares(
        uint256 offset,
        uint256 windowSize,
        uint256[] memory shares
    ) external view returns (uint256[] memory indicies);

    function getReceiversByStatuses(
        uint256 offset,
        uint256 windowSize,
        bool[] memory statuses
    ) external view returns (uint256[] memory indicies);
}
