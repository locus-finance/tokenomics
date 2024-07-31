// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

library PausabilityLib {
    error OnlyWhenNotPaused();
    
    /// @dev Slot number when the storage has been markdowned.
    bytes32 constant PAUSABILITY_STORAGE_POSITION = keccak256("diamond.standard.diamond.storage.locus.pausability");

    /// @dev Main storage markdown
    struct Storage {
        bool paused;
    }

    /// @dev Returns the storage part that manipulable through Storage struct operations.
    function get() internal pure returns (Storage storage s) {
        bytes32 position = PAUSABILITY_STORAGE_POSITION;
        assembly {
            s.slot := position
        }
    }
}