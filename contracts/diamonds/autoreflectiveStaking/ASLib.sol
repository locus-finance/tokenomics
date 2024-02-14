// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

// look for the Diamond.sol in the hardhat-deploy/solc_0.8/Diamond.sol
library ASLib {
    bytes32 constant AUTOREFLECTIVE_STAKING_STORAGE_POSITION =
        keccak256("diamond.standard.diamond.storage.autoreflective_staking");

    string public constant NAME_PREFIX = "Locus Staking";
    string public constant SYMBOL_PREFIX = "st";

    struct ReferenceTypes {
        mapping (address => uint256) rOwned;
        mapping (address => uint256) tOwned;
        mapping (address => mapping (address => uint256)) allowance;
        mapping (address => bool) isExcluded;
        EnumerableSet.AddressSet excluded;
    }

    struct Primitives {
        uint256 tTotal;
        uint256 rTotal;
        uint256 tFeeTotal;
        string name;
        string symbol;
        uint8 decimals;
    }

    struct Storage {
        Primitives p;
        ReferenceTypes rt;
    }

    function get() internal pure returns (Storage storage s) {
        bytes32 position = AUTOREFLECTIVE_STAKING_STORAGE_POSITION;
        assembly {
            s.slot := position
        }
    }
}