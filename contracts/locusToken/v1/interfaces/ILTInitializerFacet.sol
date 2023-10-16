// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

interface ILTInitializerFacet {
    /// @notice An initializer function for Locus Token inflation receivers.
    /// @param distributionReceivers Addresses of receivers (ex. Locus Staking or Vault Token Staking contracts.)
    /// @param distributionDurationPoints Durations from the start of inflation. 
    /// (If time between epochs is constant, like month for example, then all of the values would be equal to month is seconds.)
    /// @param amountsPerEpoch An amount of Locus Tokens to be minted per epoch.
    function initialize(
        address undistributedAmountsReceiver,
        address[] calldata distributionReceivers,
        uint32[] calldata distributionDurationPoints,
        uint256[][] calldata amountsPerEpoch
    ) external;
}
