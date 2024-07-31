// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

/// @title A facet that implements the autoreflective transfers and mint/burns. 
/// @author Oleg Bedrin <o.bedrin@locus.finance> - Locus Team
/// @notice The contract is meant to be utilized as a EIP2535 proxy facet. Hence it cannot be called directly and not through
/// the diamond proxy.
interface IASReflectionFacet {

    /// @notice Emits when fees that are enabled for each transfer (and the base of the fee would be an amount sent in each)
    /// and its greater then zero.
    /// @param amount An absolute amount of fees.
    event FeeReflected(uint256 indexed amount);

    /// @notice Emits when an address `who` is included or excluded from autoreflective fees gathering and staking rewards.
    /// @param who An address to receive fees or staking rewards.
    /// @param isExcluded True - an address receives. False - it does not.
    event AddressStatus(address indexed who, bool indexed isExcluded);

    /// @notice An internal diamond-wise that other facets could use to burn st-tokens from.
    /// @param who An address from whom the burn proceeds. 
    /// @param tAmount An amount of actual (non-autoreflective part of the balance) tokens to be burnt.
    function _burnFrom(address who, uint256 tAmount) external;

    /// @notice An internal diamond-wise that other facets could use to mint st-tokens to.
    /// @param who An address to whom the mint proceeds. 
    /// @param tAmount An amount of actual (non-autoreflective part of the balance) tokens to be minted.
    function _mintTo(address who, uint256 tAmount) external;

    /// @notice Excludes an address from autoreflective fees gathering and staking rewards.
    /// @dev Triggers `event AddressStatus(...)`.
    /// @param account An address to be excluded.
    function excludeAccount(address account) external;

    /// @notice Includes an address back to autoreflective fees gathering and staking rewards.
    /// @dev Triggers `event AddressStatus(...)`.
    /// @param account An address to be included back.
    function includeAccount(address account) external;

    /// @notice An internal diamond-wise that other facet that responsible for EIP20 logic would call to
    /// perform a transfer from non-excluded to non-excluded address.
    /// @param sender An address transfer is coming from.
    /// @param recipient An address transfer is coming to.
    /// @param tAmount An amount of actual (non-autoreflective part of the balance) tokens to be transferred.
    function _transferStandard(
        address sender,
        address recipient,
        uint256 tAmount
    ) external;

    /// @notice An internal diamond-wise that other facet that responsible for EIP20 logic would call to
    /// perform a transfer from non-excluded to excluded address.
    /// @param sender An address transfer is coming from.
    /// @param recipient An address transfer is coming to.
    /// @param tAmount An amount of actual (non-autoreflective part of the balance) tokens to be transferred.
    function _transferToExcluded(
        address sender,
        address recipient,
        uint256 tAmount
    ) external;

    /// @notice An internal diamond-wise that other facet that responsible for EIP20 logic would call to
    /// perform a transfer from excluded to non-excluded address.
    /// @param sender An address transfer is coming from.
    /// @param recipient An address transfer is coming to.
    /// @param tAmount An amount of actual (non-autoreflective part of the balance) tokens to be transferred.
    function _transferFromExcluded(
        address sender,
        address recipient,
        uint256 tAmount
    ) external;

    /// @notice An internal diamond-wise that other facet that responsible for EIP20 logic would call to
    /// perform a transfer from excluded to excluded address.
    /// @param sender An address transfer is coming from.
    /// @param recipient An address transfer is coming to.
    /// @param tAmount An amount of actual (non-autoreflective part of the balance) tokens to be transferred.
    function _transferBothExcluded(
        address sender,
        address recipient,
        uint256 tAmount
    ) external;

    /// @notice An internal diamond-wise that updates the reflected total supply to distribute new tokens 
    /// (a reward thats coming from the responsible entity).
    function _updateTotalReflection() external;
}
