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
extendEnvironment(require("./plugins/sentry.plugin.js"));
extendEnvironment(require("./plugins/discord.plugin.js"));

require("./tasks/utils/accounts")(task);
require("./tasks/utils/getAllArtifacts")(task);
require("./tasks/utils/verifyAll")(task);
require("./tasks/utils/sendDiscordMessage")(task);

require("./tasks/manual/observe/locusBalance")(task);
require("./tasks/manual/observe/pingProjectedAPR")(task);
require("./tasks/manual/observe/pingPrimitives")(task);
require("./tasks/manual/observe/printSendingsQueue")(task);
require("./tasks/manual/observe/printLastDeposits")(task);
require("./tasks/manual/observe/printLastWithdrawals")(task);
require("./tasks/manual/observe/printEvents")(task);

require("./tasks/manual/stakingOperations/earned")(task);
require("./tasks/manual/stakingOperations/balanceOf")(task);
require("./tasks/manual/stakingOperations/getReward")(task);
require("./tasks/manual/stakingOperations/withdraw")(task);
require("./tasks/manual/stakingOperations/stake")(task);
require("./tasks/manual/stakingOperations/totalSupply")(task);

require("./tasks/manual/autocracy/mintLocus")(task);
require("./tasks/manual/autocracy/burnLocus")(task);
require("./tasks/manual/autocracy/grantRole")(task);
require("./tasks/manual/autocracy/provideRewardForStaking")(task);
require("./tasks/manual/autocracy/clearSendingsQueue")(task);
require("./tasks/manual/autocracy/renounceAndGrantOwnership")(task);

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
    arbitrumOne: process.env.ARBISCAN_API_KEY
  }
};

module.exports = {
  solidity: {
    compilers,
  },
  mocha: {
    timeout: (900000 * 3).toString(),
  },
  networks: {
    hardhat: {
      forking: {
        url: arbitrumOneUrl,
        chainId: arbitrumOneChainId,
        // blockNumber: 205006581
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
