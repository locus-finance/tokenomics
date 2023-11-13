// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

// look for the Diamond.sol in the hardhat-deploy/solc_0.8/Diamond.sol
library LGLib {
    bytes32 constant LOCUS_GOVERNANCE_STORAGE_POSITION = keccak256("diamond.standard.diamond.storage.locus_governance");

    struct Storage {
        uint256[] proposalsIndex;
    }

    function get() internal pure returns (Storage storage s) {
        bytes32 position = LOCUS_GOVERNANCE_STORAGE_POSITION;
        assembly {
            s.slot := position
        }
    }
}