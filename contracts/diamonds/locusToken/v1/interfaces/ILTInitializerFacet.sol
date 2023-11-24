// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

interface ILTInitializerFacet {
    /// @notice An initializer function for Locus Token owner and starting state of the inflation.
    /// @param owner An address who can end and rule autocracy, and mint inflation of LCS tokens.
    function initialize(address owner) external;

    /// @notice A setter function for Locus Token inflation receivers.
    /// @param distributionReceivers Addresses of receivers (ex. Locus Staking or Vault Token Staking contracts.)
    /// @param distributionReceiversShares Shares of addresses of `distributionReceivers`.
    /// @param distributionDurationPoints Durations from the start of inflation. 
    /// (If time between epochs is constant, like month for example, then all of the values would be equal to month is seconds.)
    /// @param amountsPerEpochs An amount of Locus Tokens to be minted per epoch.
    function setupInflation(
        address[] calldata distributionReceivers,
        uint256[] calldata distributionReceiversShares,
        uint32[] calldata distributionDurationPoints,
        uint256[][] calldata amountsPerEpochs
    ) external;

    function setupTokenInfoAndEstablishAutocracy() external;
}
