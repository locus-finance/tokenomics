// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface ITDProcessFacet {
    function distribute(
        uint256 amount,
        IERC20 token
    ) external;
}
