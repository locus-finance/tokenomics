// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

/// @title This contract handles the emission control for the system, particularly the minting of inflation.
/// @author Oleg Bedrin <o.bedrin@locus.finance> - Locus Team
/// @notice The contract is meant to be utilized as a EIP2535 proxy facet. Hence it cannot be called directly and not through
/// the diamond proxy.
interface ILTEmissionControlFacet {
    /// @notice WARNING: CURRENTLY NOT USED. Mints the inflationary tokens for the current epoch and distributes them.
    /// @dev This function checks the sender's role and ensures that the inflation for the current epoch is not already distributed.
    function mintInflation() external;
}
