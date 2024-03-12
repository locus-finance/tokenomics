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

extendEnvironment(require("./plugins/names.plugin.js"));
extendEnvironment(require("./plugins/disync.plugin.js"));

require("./tasks/utils/accounts")(task);
require("./tasks/utils/getAllArtifacts")(task);
require("./tasks/manual/autocracy/mintLocus.js")(task);
require("./tasks/manual/autocracy/burnLocus.js")(task);
require("./tasks/manual/observe/pingProjectedAPR.js")(task);
require("./tasks/manual/observe/pingPrimitives.js")(task);
require("./tasks/manual/observe/errorIncident/collectStLocusBalancesAndEarned.js")(task);
require("./tasks/utils/errorIncident/collectStHoldersDataForIncident.js")(task);
require("./tasks/manual/observe/printSendingsQueue.js")(task);
require("./tasks/manual/stakingOperations/balanceOf")(task);
require("./tasks/manual/stakingOperations/getReward")(task);
require("./tasks/manual/stakingOperations/withdraw")(task);
require("./tasks/manual/stakingOperations/stake")(task);
require("./tasks/manual/autocracy/grantRole.js")(task);
require("./tasks/manual/autocracy/migrateBalances.js")(task);
require("./tasks/manual/autocracy/provideRewardForStaking.js")(task);
require("./tasks/manual/autocracy/clearSendingsQueue.js")(task);
require("./tasks/manual/autocracy/renounceAndGrantOwnership.js")(task);
require("./tasks/manual/midasClaim/getMerkleTreeInfo")(task);
require("./tasks/manual/midasClaim/updateMerkleTree")(task);
require("./tasks/manual/midasClaim/generateJsonOfMerkleTreeBody")(task);

const arbitrumOneUrl = process.env.ALCHEMY_ARBITRUM_URL;

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
    timeout: "900000",
  },
  networks: {
    hardhat: {
      forking: {
        url: arbitrumOneUrl,
        chainId: arbitrumOneChainId,
        // blockNumber: 188049440//188021861
      },
      gas: 30_000_000,
      saveDeployments: true,
      accounts: [{ privateKey: `0x${process.env.ARBITRUM_DEPLOYER_PRIVATE_KEY}`, balance: "10000000000000000000000" }],
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
