// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

interface ILSInitializerFacet {
    function initialize(
        address owner,
        address locusToken,
        address rewardDistributor,
        address rewardsToken,
        address stakingToken,
        uint32[] memory feePoints,
        uint16[] memory feeBpsPerFeePointIdx
    ) external;

    function prepareDepositary() external;

    function setFeesSettings(
        address owner,
        uint32[] memory feeDurationPoints,
        uint16[] memory feeBasePoints
    ) external;
}
