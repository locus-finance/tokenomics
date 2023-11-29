// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

interface ITDManagementFacet {
    function addReceiver(
        address feeReceiver,
        uint256 share,
        bool status
    ) external;

    function setReceiverShare(address feeReceiver, uint256 share) external;

    function setReceiverStatus(address feeReceiver, bool status) external;
}
