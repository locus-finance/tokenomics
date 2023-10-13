// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

// look for the Diamond.sol in the hardhat-deploy/solc_0.8/Diamond.sol
library LGCLib {
    bytes32 constant LOCUS_GAUGE_STORAGE_POSITION = keccak256("diamond.standard.diamond.storage.locus_gauge");

    struct Storage {
        uint256 some;
    }

    function get() internal pure returns (Storage storage s) {
        bytes32 position = LOCUS_GAUGE_STORAGE_POSITION;
        assembly {
            s.slot := position
        }
    }
}