// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

/// @title A facet which is a part of `tokenDistributor` group of facets. It allows to add new receivers of tokens and manipulate
/// their status (whether they're blocked which means they're excluded from the distribution) and their shares in a distribution.
/// @author Oleg Bedrin <o.bedrin@locus.finance> - Locus Team
/// @notice The contract is meant to be utilized as a EIP2535 proxy facet. Hence it cannot be called directly and not through
/// the diamond proxy.
interface ITDManagementFacet {
    /// @notice Adds a receiver into a token (fee) distribution.
    /// @param feeReceiver A receiver entity address.
    /// @param share A share that the receiver has to acquire.
    /// @param status A status if the receiver is blocked (excluded from the distribution) or not.
    function addReceiver(
        address feeReceiver,
        uint256 share,
        bool status
    ) external;

    /// @notice A tokens receivers share setter.
    /// @param feeReceiver A receiver entity address.
    /// @param share New share to be set.
    function setReceiverShare(address feeReceiver, uint256 share) external;

    /// @notice A tokens receivers status setter. If status is True - the address does not receive any distribution parts. Otherwise, it does.
    /// @param feeReceiver A receiver entity address.
    /// @param status New status to be set.
    function setReceiverStatus(address feeReceiver, bool status) external;
}
