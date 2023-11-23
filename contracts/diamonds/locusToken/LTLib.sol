// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

// look for the Diamond.sol in the hardhat-deploy/solc_0.8/Diamond.sol
library LTLib {
    error EpochIsDistributed(uint256 epochNumber);

    event EpochAmountIsEmptyOrInflationHasntStarted();

    bytes32 constant LOCUS_TOKEN_STORAGE_POSITION =
        keccak256("diamond.standard.diamond.storage.locus_token");

    bytes32 public constant ALLOWANCE_FREE_ROLE = keccak256('ALLOWANCE_FREE_ROLE');

    string public constant originalName = "Locus Token";
    string public constant originalSymbol = "LCS";

    uint256 public constant INITIAL_SUPPLY = 15_000_000 ether;

    struct Storage {
        mapping(uint256 => bool) isEpochsInflationDistributed;
    }

    function get() internal pure returns (Storage storage s) {
        bytes32 position = LOCUS_TOKEN_STORAGE_POSITION;
        assembly {
            s.slot := position
        }
    }
}