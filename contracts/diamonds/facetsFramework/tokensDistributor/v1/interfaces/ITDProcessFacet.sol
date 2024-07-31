// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/// @title A facet which is a part of `tokenDistributor` group of facets. It allows to perform distribution of any token that
/// is holding in the diamond according to tokens receivers their shares.
/// @author Oleg Bedrin <o.bedrin@locus.finance> - Locus Team
/// @notice The contract is meant to be utilized as a EIP2535 proxy facet. Hence it cannot be called directly and not through
/// the diamond proxy.
interface ITDProcessFacet {
    /// @notice Performs distribution of any tokens that that
    /// is holding in the diamond according to tokens receivers their shares.
    /// @param amount An amount of `token` to distribute.
    /// @param token A token to distribute.
    function distribute(
        uint256 amount,
        IERC20 token
    ) external;
}
