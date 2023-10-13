// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

// look for the Diamond.sol in the hardhat-deploy/solc_0.8/Diamond.sol
library LTLib {
    error CannotUpdateGlobalMiningParametersTooSoon();
    error InvalidTimeframe(uint256 start, uint256 end);
    error TooFarIntoFuture(uint256 timestamp);
    error InvalidRate(uint256 rate);
    error CannotMintMoreThenAvailableSupply();

    bytes32 constant LOCUS_TOKEN_STORAGE_POSITION = keccak256("diamond.standard.diamond.storage.locus_token");

    event MintedForGauge(address indexed user, address indexed gauge, uint256 indexed totalMinted);
    event UpdateMiningParameters(uint256 indexed time, uint256 indexed rate, uint256 indexed supply);

    bytes32 public constant GAUGE_CONTRACT_ROLE = keccak256('GAUGE_ROLE');
    bytes32 public constant STAKING_CONTRACT_ROLE = keccak256('STAKING_CONTRACT_ROLE');
    bytes32 public constant ALLOWANCE_FREE_ROLE = keccak256('ALLOWANCE_FREE_ROLE');

    string public constant name = "Locus Token";
    string public constant symbol = "LCS";

    uint256 public constant YEAR = 4 weeks * 12;
    
    uint256 public constant INITIAL_SUPPLY = 15_000_000 ether;
    uint256 public constant INITIAL_RATE = 0; // 274_815_283 * 10 ** 18 / YEAR  # leading to 43% premine
    uint256 public constant RATE_REDUCTION_TIME = YEAR;
    uint256 public constant RATE_REDUCTION_COEFFICIENT = 1189207115002721024; // 2 ** (1/4) * 1e18
    uint256 public constant RATE_DENOMINATOR = 10 ether;
    uint256 public constant INFLATION_DELAY = 86400;

    struct ReferenceTypes {
        // user => gauge or staking => amount
        mapping(address => mapping(address => uint256)) mintedForUser;
    }

    struct Primitives {
        int128 miningEpoch;
        uint256 startEpochTime;
        uint256 rate;
        uint256 startEpochSupply;
    }

    struct Storage {
        Primitives p;
        ReferenceTypes rt;
    }

    function get() internal pure returns (Storage storage s) {
        bytes32 position = LOCUS_TOKEN_STORAGE_POSITION;
        assembly {
            s.slot := position
        }
    }
}