require("dotenv").config();
require("hardhat-deploy");
require("@nomiclabs/hardhat-etherscan");
require("hardhat-gas-reporter");
require("solidity-coverage");
require("hardhat-docgen");
require("hardhat-abi-exporter");
require("hardhat-tracer");
require("@nomicfoundation/hardhat-chai-matchers");
require("hardhat-contract-sizer");

require("./tasks/accounts")(task);
require("./tasks/getAllArtifacts")(task);
require("./tasks/autocracyMintLocus")(task);
require("./tasks/midasClaim/getMerkleTreeInfo")(task);
require("./tasks/midasClaim/updateMerkleTree")(task);
require("./tasks/midasClaim/generateJsonOfMerkleTreeBody")(task);

const mainnetUrl = `https://eth-mainnet.g.alchemy.com/v2/${process.env.ALCHEMY_MAINNET_API_KEY}`;
const sepoliaUrl = `https://eth-sepolia.g.alchemy.com/v2/${process.env.ALCHEMY_SEPOLIA_API_KEY}`;
const arbitrumOneUrl = 'https://arb1.arbitrum.io/rpc';

const mainnetChainId = 1;
const sepoliaChainId = 11155111;
const arbitrumOneChainId = 42161;

const optimizer = {
  enabled: true,
  runs: 1,
};

const compilers = [
  {
    version: "0.8.19",
    settings: {
      viaIR: true,
      optimizer,
    },
  },
];

extendEnvironment(require("./names.plugin.js"));

const etherscan = {
  apiKey: {
    mainnet: process.env.ETHERSCAN_API_KEY,
    sepolia: process.env.ETHERSCAN_API_KEY,
    arbitrumOne: process.env.ARBISCAN_API_KEY
  }
};

module.exports = {
  solidity: {
    compilers,
  },
  mocha: {
    timeout: "100000",
  },
  networks: {
    hardhat: {
      forking: {
        url: arbitrumOneUrl,
        chainId: arbitrumOneChainId,
      },
      saveDeployments: true,
    },
    mainnet: {
      url: mainnetUrl,
      chainId: mainnetChainId,
      accounts: { mnemonic: process.env.MAINNET_DEPLOY_MNEMONIC },
      saveDeployments: true,
    },
    sepolia: {
      url: sepoliaUrl,
      chainId: sepoliaChainId,
      accounts: { mnemonic: process.env.TESTNET_DEPLOY_MNEMONIC },
      saveDeployments: true,
    },
    arbitrumOne: {
      url: arbitrumOneUrl,
      chainId: arbitrumOneChainId,
      accounts: [`0x${process.env.ARBITRUM_DEPLOYER_PRIVATE_KEY}`],
      saveDeployments: true,
    },
  },
  namedAccounts: {
    deployer: 0,
    user1: 1,
    user2: 2,
    treasury: 3
  },
  gasReporter: {
    enabled: process.env.REPORT_GAS === "true" ? true : false,
    currency: "USD",
  },
  etherscan,
  verify: {
    etherscan
  },
  docgen: {
    path: "./docs",
    clear: true,
    runOnCompile: process.env.DOCGEN === "true" ? true : false,
  },
  abiExporter: {
    path: "./abis",
    flat: false,
    format: "json",
  },
  contractSizer: {
    alphaSort: true,
    disambiguatePaths: false,
    runOnCompile: true,
  },
};
