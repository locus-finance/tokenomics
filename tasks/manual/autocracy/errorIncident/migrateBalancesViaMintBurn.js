const { parseCSV } = require("../../../../deploy/helpers");
const fsExtra = require("fs-extra");
module.exports = (task) =>
  task(
    "migrateBalancesViaMintBurn",
    "Migrates the balances of an old Locus Staking to new Autoreflective Locus Staking via force burn and mint of LOCUS\'.",
  )
    .addOptionalParam("locus", "Define a name or address of LOCUS token contract in hre.names.", '', types.string)
    .addOptionalParam("old", "A file name that should be used when caching users with balances in old staking contract.", '', types.string)
    .addOptionalParam("latest", "A file name that should be used when caching users with balances in old staking contract.", '', types.string)
    .addOptionalParam("csv", "A CSV table of users to migrate balances for.", './resources/csv/allLocusHolders.csv', types.string)
    .setAction(async ({ locus, csv, old, latest }, hre) => {
      await hre.names.gather();

      const oldStakingAddress = old === '' ? (await hre.deployments.get(hre.names.internal.diamonds.locusStaking.proxy)).address : old;
      const latestStakingAddress = latest === '' ? (await hre.deployments.get(hre.names.internal.diamonds.autoreflectionStaking.proxy)).address : latest;
      const locusAddress = locus !== '' ? locus : (await hre.deployments.get(hre.names.internal.diamonds.locusToken.proxy)).address

      const oldStakingInstance = await hre.ethers.getContractAt(
        hre.names.internal.diamonds.locusStaking.interface,
        oldStakingAddress
      );
      const locusInstance = await hre.ethers.getContractAt(
        hre.names.internal.diamonds.locusToken.interface,
        locus
      );

      //   const parsed = await parseCSV(["HolderAddress"], csv);
      //   let holdersWithBalanceInOldStaking = [];
      //   for (let i = 0; i < parsed.length; i++) {
      //     const holder = parsed[i];
      //     const oldBalance = await oldStakingInstance.balanceOf(holder.HolderAddress);
      //     const isBalanceGt0 = oldBalance.gt(0); 
      //     if (isBalanceGt0) {
      //       holdersWithBalanceInOldStaking.push({
      //         address: holder.HolderAddress,
      //         balance: hre.ethers.utils.formatEther(oldBalance)
      //       });
      //     }
      //     console.log(`Checking account: ${holder.HolderAddress} - ${i} of ${parsed.length} - has staking deposit: ${isBalanceGt0}`);
      //   }
      //   console.log(`Gathered ${holdersWithBalanceInOldStaking.length} addresses with stake deposit. Constructing the call...`);

      //   let csvString = "\"address\",\"balance\"\n";
      //   for (const filteredHolder of holdersWithBalanceInOldStaking) {
      //     csvString += `${filteredHolder.address},${filteredHolder.balance.toString()}\n`;
      //   }
      //   await fsExtra.outputFile(filtered, csvString);

      //   const listOfAddressesForCalldata = holdersWithBalanceInOldStaking.map(e => e.address);

      //   const migrationTx = await oldStakingInstance.migrateBalances(
      //     listOfAddressesForCalldata,
      //     latestStakingAddress,
      //     0
      //   );
      //   await migrationTx.wait();

      //   console.log(`Migration was complete:\n${JSON.stringify(migrationTx)}`);
    });
