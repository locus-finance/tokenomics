// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

interface ILSInitializerFacet {
    function initialize(
        address owner,
        address votingEscrow,
        address rewardDistributor,
        address rewardsToken,
        address stakingToken
    ) external;
}
