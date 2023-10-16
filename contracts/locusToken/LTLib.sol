// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

// look for the Diamond.sol in the hardhat-deploy/solc_0.8/Diamond.sol
library LTLib {
    bytes32 public constant INFLATION_RECEIVER_ROLE = keccak256('INFLATION_RECEIVER_ROLE');
    bytes32 public constant ALLOWANCE_FREE_ROLE = keccak256('ALLOWANCE_FREE_ROLE');

    string public constant name = "Locus Token";
    string public constant symbol = "LCS";

    uint256 public constant INITIAL_SUPPLY = 15_000_000 ether;
}