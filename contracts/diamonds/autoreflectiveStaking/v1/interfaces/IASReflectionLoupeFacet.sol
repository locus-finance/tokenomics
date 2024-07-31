// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "../../ASLib.sol";

/// @title A facet that implements the observation of autoreflective math inside the staking contract.
/// @author Oleg Bedrin <o.bedrin@locus.finance> - Locus Team
/// @notice The contract is meant to be utilized as a EIP2535 proxy facet. Hence it cannot be called directly and not through
/// the diamond proxy.
interface IASReflectionLoupeFacet {
    /// @notice Checks if an account were either inlcuded or excluded from fees and staking rewards distribution.
    /// @param account An account to be checked.
    /// @return True if an address is excluded. False - if it does not.
    function isExcluded(address account) external view returns (bool);

    /// @notice Returns a reflected amount against real amount of share tokens.
    /// @param tAmount A real amount of share tokens.
    /// @param addTransferFee An account the fees that could be applied.
    /// @return A reflected amount of share tokens.
    function reflectionFromToken(
        uint256 tAmount,
        bool addTransferFee
    ) external view returns (uint256);

    /// @notice Returns a real amount against reflected amount of share tokens.
    /// @param rAmount A reflected amount of share tokens.
    /// @return A real amount of share tokens.
    function tokenFromReflection(
        uint256 rAmount
    ) external view returns (uint256);

    /// @notice An internal diamond-wise view function that calculates both sides of the balance: reflected and real.
    /// @param tAmount An amount of real share tokens to be calculated based on.
    /// @return A struct which represents both sides of the balance.
    function _getValues(
        uint256 tAmount
    ) external view returns (ASLib.Values memory);

    /// @notice An internal diamond-wise view function that calculates real side of the balance.
    /// @param tAmount An amount of real share tokens to be calculated based on.
    /// @return A struct which represents real side of the balance.
    function _getTValues(
        uint256 tAmount
    ) external view returns (ASLib.TValues memory);

    /// @notice An internal diamond-wise view function that calculates reflected side of the balance.
    /// @param tAmount An amount of real share tokens to be calculated based on.
    /// @param tFee An amount of fee per transaction (currently 0) in real share tokens.
    /// @param currentRate An amount which represents the transformation rate between real and reflected total supply.
    /// @return A struct which represents reflected side of the balance.
    function _getRValues(
        uint256 tAmount,
        uint256 tFee,
        uint256 currentRate
    ) external view returns (ASLib.RValues memory);

    /// @notice An internal diamond-wise view function that returns an amount which represents 
    /// the transformation rate between real and reflected total supply.
    function _getRate() external view returns (uint256);

    /// @notice An internal diamond-wise view function that returns current state of both real and reflected
    /// total supplies but accounting excluded and included addresses.
    function _getCurrentSupply() external view returns (ASLib.Supply memory);

    /// @notice Returns whole state of the primitive variables in the diamond.
    function getPrimitives() external view returns (ASLib.Primitives memory);
}
