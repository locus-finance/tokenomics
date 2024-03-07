const { types } = require("hardhat/config");
const { parseCSV } = require("../../deploy/helpers");
const fsExtra = require("fs-extra");

module.exports = (task) =>
  task(
    "collect",
    "Collect and store stLOCUS balances.",
  )
    .addOptionalParam("collected", "A file name that should be used when collecting users with balances in staking contract.", './resources/csv/collectedStLocusHolders.csv', types.string)
    .addOptionalParam("csv", "A CSV table of LOCUS\' holders.", './resources/csv/allLocusHolders.csv', types.string)
    .addOptionalParam("staking", "Define a name or address of staking contract in hre.names.", '', types.string)
    .setAction(async ({ staking, csv, collected }, hre) => {
      await hre.names.gather();
      staking = staking !== '' ? staking : (await hre.deployments.get(hre.names.internal.diamonds.locusStaking.proxy)).address;
      const stakingInstance = await hre.ethers.getContractAt(
        hre.names.internal.diamonds.locusStaking.interface,
        staking
      );
      const parsed = await parseCSV(["HolderAddress"], csv);
      let holdersWithBalanceInOldStaking = [];
      for (let i = 0; i < parsed.length; i++) {
        const holder = parsed[i];
        const oldBalance = await stakingInstance.balanceOf(holder.HolderAddress);
        holdersWithBalanceInOldStaking.push({
            address: holder.HolderAddress,
            balance: hre.ethers.utils.formatEther(oldBalance)
        });
        console.log(`Collecting account: ${holder.HolderAddress} - ${i} of ${parsed.length}`);
      }
      console.log(`Gathered ${holdersWithBalanceInOldStaking.length} addresses with stake deposit. Saving...`);

      let csvString = "\"address\",\"balance\"\n";
      for (const filteredHolder of holdersWithBalanceInOldStaking) {
        csvString += `${filteredHolder.address},${filteredHolder.balance.toString()}\n`;
      }
      await fsExtra.outputFile(collected, csvString);
      console.log('Saved.')
    });
