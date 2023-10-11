// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

interface IERC20CappedFacet {
    function mintTo(address account, uint256 amount) external;

    function burnFrom(address account, uint256 amount) external;

    function _init_ERC20CappedFacet() external;
}
