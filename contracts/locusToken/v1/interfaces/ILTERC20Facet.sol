// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

interface ILTERC20Facet {
    function mintTo(address account, uint256 amount) external;

    function burnFrom(address account, uint256 amount) external;

    function _init_LTERC20Facet() external;
}
