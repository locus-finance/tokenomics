// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

interface ILSInitializerFacet {
    function initialize(
        address owner,
        address rewardDistributor,
        address rewardsToken,
        address stakingToken
    ) external;

    function prepareDepositary() external;

    function setWrappedStakingLocus(address wrappedStLocusToken) external;

    function migrateBalances(address[] memory users, address autoreflectiveStaking, uint256 startOffset) external;
}
