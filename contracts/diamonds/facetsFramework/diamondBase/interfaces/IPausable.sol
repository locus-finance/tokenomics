// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

/// @title A base facet that establishes the pausability functionality. 
/// @author Oleg Bedrin <o.bedrin@locus.finance> - Locus Team
/// @notice The contract is meant to be utilized as a EIP2535 proxy facet. Hence it cannot be called directly and not through
/// the diamond proxy.
interface IPausable {
    /// @notice Returns if the diamond has been paused or not.
    function pause() external;

    /// @notice Pauses the diamond.
    function unpause() external;

    /// @notice Unpauses the diamond.
    function paused() external view returns (bool);
}
