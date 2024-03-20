const { types } = require("hardhat/config");
const fsExtra = require("fs-extra");

module.exports = (task) =>
  task(
    "clearRemainingWithdrawalsQueue",
    "Clears remaining deque of withdrawals of LOCUS\' from the old staking.",
  )
    .addOptionalParam("locus", "Define a name or address of LOCUS token contract in hre.names.", '', types.string)
    .addOptionalParam("json", "A json data of remaining delayed sendings.", './resources/json/errorIncident/withdrawsDequePostErrorInOldStaking.json', types.string)
    .addOptionalParam("confirmations", "An amount of confirmations to wait each iteration of incident liquidation.", 10, types.int)
    .setAction(async ({ locus, json, confirmations }, hre) => {
      await hre.names.gather();
      if (initialOffset > 0) {
        console.log(`WARNING: groups numeration would be from 0! Set up initial offset: ${initialOffset}`);
      }

      const dequeData = await fsExtra.readJSON(json);
      const locusAddress = locus !== '' ? locus : (await hre.deployments.get(hre.names.internal.diamonds.locusToken.proxy)).address

      const locusInstance = await hre.ethers.getContractAt(
        hre.names.internal.diamonds.locusToken.interface,
        locusAddress
      );
      
      // const sendings

    });
