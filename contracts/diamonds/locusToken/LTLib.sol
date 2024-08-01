// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

// look for the Diamond.sol in the hardhat-deploy/solc_0.8/Diamond.sol
library LTLib {
    error EpochIsDistributed(uint256 epochNumber);

    /// @notice Emits when there is no amount to distribute or inflation has not started for the current epoch yet.
    event EpochAmountIsEmptyOrInflationHasntStarted();

    /// @dev Slot number when the storage has been markdowned.
    bytes32 constant LOCUS_TOKEN_STORAGE_POSITION =
        keccak256("diamond.standard.diamond.storage.locus_token");

    /// @dev Classic `AccessControl` role. Allows the bearer to skip allowance operations.
    bytes32 public constant ALLOWANCE_FREE_ROLE = keccak256('ALLOWANCE_FREE_ROLE');

    string public constant originalName = "Locus Token";
    string public constant originalSymbol = "LOCUS";

    /// @notice The initial supply of the Governance token, set to 15 million tokens (with 18 decimals).
    uint256 public constant INITIAL_SUPPLY = 15_000_000 ether;

    /// @dev Main storage markdown
    struct Storage {
        mapping(uint256 => bool) isEpochsInflationDistributed;
    }

    /// @dev Returns the storage part that manipulable through Storage struct operations.
    function get() internal pure returns (Storage storage s) {
        bytes32 position = LOCUS_TOKEN_STORAGE_POSITION;
        assembly {
            s.slot := position
        }
    }
}