// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "../../TDLib.sol";

/// @title A facet which is a part of `tokenDistributor` group of facets. It allows to loupe through the data of 
/// receivers of tokens and their shares. 
/// @author Oleg Bedrin <o.bedrin@locus.finance> - Locus Team
/// @notice The contract is meant to be utilized as a EIP2535 proxy facet. Hence it cannot be called directly and not through
/// the diamond proxy.
interface ITDLoupeFacet {

    /// @notice Returns indicies of token receivers in the main array based on their addresses.
    /// @param offset An amount of indicies to skip before the window scan.
    /// @param windowSize A size of a window inside which the search would occur.
    /// @param addresses A group of addresses to search for.
    /// @return indicies A group of indicies at which the addresses are in the main array.
    function getReceiversByAddresses(
        uint256 offset,
        uint256 windowSize,
        address[] memory addresses
    ) external view returns (uint256[] memory indicies);

    /// @notice Returns indicies of token receivers in the main array based on their shares.
    /// @param offset An amount of indicies to skip before the window scan.
    /// @param windowSize A size of a window inside which the search would occur.
    /// @param shares A group of share balances to search for.
    /// @return indicies A group of indicies at which the addresses are in the main array.
    function getReceiversByShares(
        uint256 offset,
        uint256 windowSize,
        uint256[] memory shares
    ) external view returns (uint256[] memory indicies);

    /// @notice Returns indicies of token receivers in the main array based on their status (whether they're blocked or not).
    /// @param offset An amount of indicies to skip before the window scan.
    /// @param windowSize A size of a window inside which the search would occur.
    /// @param statuses A group of statuses to search for.
    /// @return indicies A group of indicies at which the addresses are in the main array.
    function getReceiversByStatuses(
        uint256 offset,
        uint256 windowSize,
        bool[] memory statuses
    ) external view returns (uint256[] memory indicies);
}
