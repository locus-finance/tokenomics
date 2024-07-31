// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

library InitializerLib {
    error AlreadyInitialized();
    /// @dev Only use it with template facets.
    error NotImplemented();

    /// @dev Slot number when the storage has been markdowned.
    bytes32 constant INITIALIZER_STORAGE_POSITION = keccak256("diamond.standard.diamond.storage.locus.initializer");

    /// @dev Main storage markdown
    struct Storage {
        bool initialized; // if the diamond is initialized
    }

    /// @dev Returns the storage part that manipulable through Storage struct operations.
    function get() internal pure returns (Storage storage s) {
        bytes32 position = INITIALIZER_STORAGE_POSITION;
        assembly {
            s.slot := position
        }
    }

    /// @dev Resets the initialized state. (currently is nor present in the facets)
    function reset() internal {
        get().initialized = false;
    }

    /// @dev Set the diamond initalized.
    function initialize() internal {
        if (get().initialized) {
            revert AlreadyInitialized();
        } else {
            get().initialized = true;
        }
    }
}