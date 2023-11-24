// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

// look for the Diamond.sol in the hardhat-deploy/solc_0.8/Diamond.sol
library AutocracyLib {
    bytes32 constant LOCUS_TOKEN_AUTOCRACY_STORAGE_POSITION = keccak256("diamond.standard.diamond.storage.locus_token.autocracy");

    bytes32 public constant AUTOCRAT_ROLE = keccak256('AUTOCRAT_ROLE');
    bytes32 public constant REVOLUTIONARY_ROLE = keccak256('REVOLUTIONARY_ROLE');

    struct Storage {
        // True - then the tokens can be transferrable only to a restricted set of addresses.
        bool isAutocracyEnabled;
    }

    function get() internal pure returns (Storage storage s) {
        bytes32 position = LOCUS_TOKEN_AUTOCRACY_STORAGE_POSITION;
        assembly {
            s.slot := position
        }
    }
}