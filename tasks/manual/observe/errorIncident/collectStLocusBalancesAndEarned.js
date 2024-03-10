const { types } = require("hardhat/config");
const { parseCSV } = require("../../../../deploy/helpers");
const fsExtra = require("fs-extra");

module.exports = (task) =>
  task(
    "collect",
    "Collect and store stLOCUS balances.",
  )
    .addOptionalParam("collected", "A file name that should be used when collecting users with balances in staking contract.", './resources/csv/errorIncident/collectedStLocusHoldersPreError.csv', types.string)
    .addOptionalParam("csv", "A CSV table of LOCUS\' holders.", './resources/csv/errorIncident/allLocusHoldersPreError.csv', types.string)
    .addOptionalParam("staking", "Define a name or address of staking contract in hre.names.", '', types.string)
    .addOptionalParam("locus", "Define a name or address of LOCUS token contract in hre.names.", '', types.string)
    .setAction(async ({ locus, staking, csv, collected }, hre) => {
      if (!hre.names.isInitialized()) {
        await hre.names.gather();
      }

      staking = staking !== '' ? staking : (await hre.deployments.get(hre.names.internal.diamonds.locusStaking.proxy)).address;
      locus = locus !== '' ? locus : (await hre.deployments.get(hre.names.internal.diamonds.locusToken.proxy)).address
      
      const stakingInstance = await hre.ethers.getContractAt(
        hre.names.internal.diamonds.locusStaking.interface,
        staking
      );
      const locusInstance = await hre.ethers.getContractAt(
        hre.names.internal.diamonds.locusToken.interface,
        locus
      );
      const parsed = await parseCSV(["HolderAddress"], csv);
      let holdersWithBalanceAndEarned = [];
      let sumOfEarned = hre.ethers.constants.Zero;
      let sumOfBalances = hre.ethers.constants.Zero;
      for (let i = 0; i < parsed.length; i++) {
        const holder = parsed[i];
        const balance = await stakingInstance.balanceOf(holder.HolderAddress);
        const earned = await stakingInstance.earned(holder.HolderAddress);
        sumOfEarned = sumOfEarned.add(earned);
        sumOfBalances = sumOfBalances.add(balance);
        holdersWithBalanceAndEarned.push({
            address: holder.HolderAddress,
            balance: hre.ethers.utils.formatEther(balance),
            earned: hre.ethers.utils.formatEther(earned)
        });
        console.log(`Collecting account: ${holder.HolderAddress} - ${i + 1} of ${parsed.length}`);
      }
      console.log(`Gathered ${holdersWithBalanceAndEarned.length} addresses with stake deposit and earned position. Saving...`);

      let csvString = "\"address\",\"balance\",\"earned\"\n";
      for (const filteredHolder of holdersWithBalanceAndEarned) {
        csvString += `\"${filteredHolder.address}\",\"${filteredHolder.balance.toString()}\",\"${filteredHolder.earned.toString()}\"\n`;
      }
      await fsExtra.outputFile(collected, csvString);
      console.log('Saved.');
      const balanceOfStLocus = await locusInstance.balanceOf(stakingInstance.address);
      const totalReward = await stakingInstance.getTotalReward();
      console.log('--- Total sums ---');
      console.log(`locus.balanceOf(stLOCUS): ${hre.ethers.utils.formatEther(balanceOfStLocus)}`);
      console.log(`stLOCUS.getTotalReward(): ${hre.ethers.utils.formatEther(totalReward)}`);
      console.log(`Sum of earned: ${hre.ethers.utils.formatEther(sumOfEarned)}`);
      console.log(`Sum of balances: ${hre.ethers.utils.formatEther(sumOfBalances)}`);
      console.log(`Total Sum (sum of earned + sum of balances + total reward): ${hre.ethers.utils.formatEther(sumOfEarned.add(sumOfBalances).add(totalReward))}`);
      const difference = balanceOfStLocus.sub(sumOfEarned.add(sumOfBalances).add(totalReward));
      console.log(`Difference between locus.balanceOf(stLOCUS) and (sum of earned + sum of balances + total reward): ${hre.ethers.utils.formatEther(difference)}`);
    });
