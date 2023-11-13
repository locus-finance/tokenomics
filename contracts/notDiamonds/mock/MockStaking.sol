// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract MockStaking {
    address public locusToken;

    mapping(address => uint256) public sent;

    using SafeERC20 for IERC20;

    constructor(address _token) {
        locusToken = _token;
    }

    function stakeFor(address account, uint256 amount) external {
        IERC20(locusToken).safeTransferFrom(msg.sender, address(this), amount);
        sent[account] += amount;
    }
}
