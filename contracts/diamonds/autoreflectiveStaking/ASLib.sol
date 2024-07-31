// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

// look for the Diamond.sol in the hardhat-deploy/solc_0.8/Diamond.sol
library ASLib {
    error CannotApproveFromZeroAddress();
    error CannotApproveToZeroAddress();
    error CannotTransferFromZeroAddress();
    error CannotTransferToZeroAddress();
    error AmountCannotBeZero();
    error AddressIsExcludedFromFees();
    error AlreadyExcluded(address who);
    error AlreadyIncluded(address who);
    error AmountIsLessThan(uint256 actual, uint256 expected);
    error CannotRecognizeAddressesInExcludedList(address from, address to);

    /// @dev Share token supply structure.
    struct Supply {
        uint256 rSupply; // reflected total supply
        uint256 tSupply; // real total supply
    }

    /// @dev A container to pack real and reflected values.
    struct Values {
        RValues r; // reflected value of share token
        TValues t; // real value of share token
    }

    /// @dev A container to pack reflected values.
    struct RValues {
        uint256 rAmount; // reflected value of share token
        uint256 rTransferAmount; // reflected value of share token to be transferred (might differ from `rAmount` if fees > 0)
        uint256 rFee; // an amount of reflected fee on a transfer of share token (currently - reflected 0)
    }

    /// @dev A container to pack real values.
    struct TValues {
        uint256 tTransferAmount; // real value of share token to be transferred (might differ from actual transfer amount if fees > 0)
        uint256 tFee; // an amount of real fee on a transfer of share token (currently - 0)
    }

    /// @dev Slot number when the storage has been markdowned.
    bytes32 constant AUTOREFLECTIVE_STAKING_STORAGE_POSITION =
        keccak256("diamond.standard.diamond.storage.autoreflective_staking");
    
    /// @dev Classic `AccessControl` role.
    bytes32 public constant REWARD_DISTRIBUTOR_ROLE = keccak256("REWARD_DISTRIBUTOR_ROLE");

    string public constant NAME_PREFIX = "Locus Staking";
    string public constant SYMBOL_PREFIX = "st";

    /// @dev A container for reference types in the storage.
    struct ReferenceTypes {
        // user => reflected balance
        mapping (address => uint256) rOwned;
        // user => real balance
        mapping (address => uint256) tOwned;
        // classic EIP20 allowance
        mapping (address => mapping (address => uint256)) allowance;
        // an enumerable set of excluded from fees and rewards users or entities 
        EnumerableSet.AddressSet excluded;
    }

    /// @dev A container for primitive types in the storage.
    struct Primitives {
        address token; // a token to be staked.
        uint256 tTotal; // actual real total supply
        uint256 rTotal; // actual reflected total supply
        uint256 tFeeTotal; // fees gathed totally in real form
        string name; // EIP20 name
        string symbol; // EIP20 symbol
        uint8 decimals; // EIP20 decimals
        uint256 totalStaked; // total `token` tokens staked
    }

    /// @dev Main storage markdown
    struct Storage {
        Primitives p;
        ReferenceTypes rt;
    }

    /// @dev Returns the storage part that manipulable through Storage struct operations.
    function get() internal pure returns (Storage storage s) {
        bytes32 position = AUTOREFLECTIVE_STAKING_STORAGE_POSITION;
        assembly {
            s.slot := position
        }
    }
}