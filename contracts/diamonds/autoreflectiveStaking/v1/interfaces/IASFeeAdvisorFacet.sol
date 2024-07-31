// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

/// @title A facet that implements the fee calculation logic. 
/// @author Oleg Bedrin <o.bedrin@locus.finance> - Locus Team
/// @notice The contract is meant to be utilized as a EIP2535 proxy facet. Hence it cannot be called directly and not through
/// the diamond proxy.
interface IASFeeAdvisorFacet {
    /// @notice Returns the amount of fee based on who and what amount be transferred and placed fee upon. 
    /// For now returns constantly zero.
    /// @param amount An amount of tokens of an entity which the advise about fees be based on.
    /// @return Constant 0.
    function advise(uint256 amount) external view returns (uint256);
}
