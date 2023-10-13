// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

interface ILSFeesManagementFacet {
    function addFeeReceiver(
        address feeReceiver,
        uint256 share,
        bool status
    ) external;

    function setFeeReceiverShare(address feeReceiver, uint256 share) external;

    function setFeeReceiverStatus(address feeReceiver, bool status) external;
}
