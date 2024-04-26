// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

// look for the Diamond.sol in the hardhat-deploy/solc_0.8/Diamond.sol
library AutocracyGovernmentLib {
    bytes32 constant LOCUS_TOKEN_AUTOCRACY_GOVERNMENT_STORAGE_POSITION = keccak256("diamond.standard.diamond.storage.locus_token.autocracy.government");

    struct Storage {
        // entity (caller) => selector => is allowed to call that function
        mapping(address => mapping(bytes4 => bool)) entityToSelectorToAllowedToCall;
    }

    function get() internal pure returns (Storage storage s) {
        bytes32 position = LOCUS_TOKEN_AUTOCRACY_GOVERNMENT_STORAGE_POSITION;
        assembly {
            s.slot := position
        }
    }
}