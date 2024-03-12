// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

interface ILTIncidentLiquidatorFacet {
    error MustBeEqual(uint256 a, uint256 b);

    event IncidentLiquidatedFor(address who, uint256 amount);

    function liquidateIncident(
        address oldStaking,
        address autoreflectiveStaking,
        uint256 expectedLocusAmountToBeWithdrawn,
        address[] calldata users,
        uint256[] calldata amounts,
        uint256[] calldata locusAmounts
    ) external;
}
