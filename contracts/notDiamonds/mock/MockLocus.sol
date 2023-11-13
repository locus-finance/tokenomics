// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MockLocus is ERC20 {
    constructor(address initialOwner) ERC20("Locus Mock", "MLT") {}

    function mint(address account, uint256 amount) external {
        _mint(account, amount);
    }
}
