// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

interface ILTIncidentLiquidatorFacet {
    error MustBeLessThanOrEqualTo(uint256 actual, uint256 expected);
    error MustBeEqual(uint256 a, uint256 b);

    event IncidentLiquidatedFor(address who, uint256 amount);
    event RemainderSent(uint256 remainderAmount);

    function liquidateIncident(
        address oldStaking,
        address autoreflectiveStaking,
        address[] calldata users,
        uint256[] calldata amounts
    ) external;
}
