// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Capped.sol";

contract LocusToken is ERC20Capped, Ownable {

    uint256 private constant _CAP = 15_000_000 ether;

    constructor()
        ERC20("Locus Token", "LCS")
        ERC20Capped(_CAP)
        Ownable(_msgSender())
    {
        _mint(_msgSender(), _CAP);
    }

    function burn(address account, uint256 amount) external onlyOwner {
        _burn(account, amount);
    }

    function mint(address account, uint256 amount) external onlyOwner {
        _mint(account, amount);
    }
}