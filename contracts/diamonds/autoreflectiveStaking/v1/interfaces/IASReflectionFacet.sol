// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

interface IASReflectionFacet {
    event FeeReflected(uint256 indexed amount);
    event AddressStatus(address indexed who, bool indexed isExcluded);

    function _burnFrom(address who, uint256 tAmount) external;

    function _mintTo(address who, uint256 tAmount) external;

    function excludeAccount(address account) external;

    function includeAccount(address account) external;

    function _transferStandard(
        address sender,
        address recipient,
        uint256 tAmount
    ) external;

    function _transferToExcluded(
        address sender,
        address recipient,
        uint256 tAmount
    ) external;

    function _transferFromExcluded(
        address sender,
        address recipient,
        uint256 tAmount
    ) external;

    function _transferBothExcluded(
        address sender,
        address recipient,
        uint256 tAmount
    ) external;
}
