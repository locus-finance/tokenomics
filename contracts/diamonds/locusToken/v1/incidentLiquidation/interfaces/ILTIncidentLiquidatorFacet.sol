// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

interface ILTIncidentLiquidatorFacet {
    error MustBeEqual(uint256 a, uint256 b);

    event PersonalTreatment(
        address indexed user,
        bool indexed isBurnOrMint,
        uint256 indexed locusAmount
    );
    event IncidentLiquidatedFor(
        address indexed who,
        uint256 indexed stLocusAmount,
        uint256 indexed locusAmount
    );
    event ForceStaked(address indexed who, uint256 indexed stLocusAmount);
    event TotalMinted(uint256 indexed amount);

    function liquidateIncident(
        address oldStaking,
        address autoreflectiveStaking,
        address[] calldata users,
        uint256[] calldata stLocusAmounts,
        uint256[] calldata locusAmounts
    ) external;

    function personalTreatment(
        address user,
        uint256 expectedAmount,
        uint256 oldStLocusAmount,
        uint256 soldAmount,
        uint256 lessThenTimes
    ) external;

    function forceStakeFor(
        address user,
        uint256 amount,
        address autoreflectiveStaking
    ) external;

    function massMint(address[] calldata users, uint256[] calldata amounts) external;
}
