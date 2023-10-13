// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

interface ILTEmissionControlFacet {
    function updateMiningParameters() external;

    function globalUpdateMiningParameters() external;

    function startEpochTimeWrite() external returns (uint256);

    function futureEpochTimeWrite() external returns (uint256);

    function availableSupply() external view returns (uint256);

    function mintableInTimeframe(
        uint256 start,
        uint256 end
    ) external view returns (uint256);
}
