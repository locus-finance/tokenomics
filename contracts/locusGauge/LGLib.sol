// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

// look for the Diamond.sol in the hardhat-deploy/solc_0.8/Diamond.sol
library LGLib {
    bytes32 constant LOCUS_GAUGE_STORAGE_POSITION = keccak256("diamond.standard.diamond.storage.locus_gauge");

    uint256 public constant TOKENLESS_PRODUCTION = 40;
    uint256 public constant BOOST_WARMUP = 2 * 7 * 86400;
    uint256 public constant YEAR = 4 weeks * 12;

    struct ReferenceTypes {
        mapping(address => uint256) balanceOf;
        // # caller -> recipient -> can deposit?
        mapping(address => mapping(address => bool)) approvedToDeposit;
        mapping(address => uint256) workingBalances;
        uint256[] periodTimestamp;
        // # 1e18 * ∫(rate(t) / totalSupply(t) dt) from 0 till checkpoint
        uint256[] integrateInvSupply;
        // # 1e18 * ∫(rate(t) / totalSupply(t) dt) from (last_action) till checkpoint
        mapping(address => uint256) integrateInvSupplyOf;
        mapping(address => uint256) integrateCheckpointOf;
        // # ∫(balance * rate(t) / totalSupply(t) dt) from 0 till checkpoint
        // # Units: rate * t = already number of coins per address to issue
        mapping(address => uint256) integrateFraction;
    }

    struct Primitives { 
        address locusToken;
        address vaultToken;
        address controller;
        address votingEscrow;
        uint256 totalSupply;
        uint256 futureEpochTime;
        uint256 workingSupply;
        // The goal is to be able to calculate ∫(rate * balance / totalSupply dt) from 0 till checkpoint
        // All values are kept in units of being multiplied by 1e18
        int128 period;
        uint256 inflationRate;
        bool isStopped;
    }

    struct Storage {
        Primitives p;
        ReferenceTypes rt;
    }

    function get() internal pure returns (Storage storage s) {
        bytes32 position = LOCUS_GAUGE_STORAGE_POSITION;
        assembly {
            s.slot := position
        }
    }
}