const { types } = require("hardhat/config");
const fsExtra = require("fs-extra");

module.exports = (task) =>
  task(
    "migrateBalancesViaMintBurn",
    "Migrates the balances both of classic LOCUS\' and of the old Locus Staking to the new Autoreflective Locus Staking via force burn and mint of LOCUS\'.",
  )
    .addOptionalParam("locus", "Define a name or address of LOCUS token contract in hre.names.", '', types.string)
    .addOptionalParam("old", "An address of the old staking contract.", '', types.string)
    .addOptionalParam("latest", "An address of the new staking contract.", '', types.string)
    .addOptionalParam("jsonWithoutLuckies", "A json data piece of users to migrate balances for.", './resources/json/errorIncident/stLocusHoldersDataForIncidentAnalysisWithoutLuckies.json', types.string)
    .addOptionalParam("confirmations", "An amount of confirmations to wait each iteration of incident liquidation.", 10, types.int)
    .addOptionalParam("initialOffset", "An offset for realigning the group processing.", 0, types.int)
    .setAction(async ({ locus, jsonWithoutLuckies, old, confirmations, initialOffset, latest }, hre) => {
      await hre.names.gather();
      if (initialOffset > 0) {
        console.log('WARNING: group numeration would be from 0!');
      }

      const incidentData = await fsExtra.readJSON(jsonWithoutLuckies);

      const oldStakingAddress = old === '' ? (await hre.deployments.get(hre.names.internal.diamonds.locusStaking.proxy)).address : old;
      const locusAddress = locus !== '' ? locus : (await hre.deployments.get(hre.names.internal.diamonds.locusToken.proxy)).address
      const newStakingAddress = latest === '' ? (await hre.deployments.get(hre.names.internal.diamonds.autoreflectiveStaking.proxy)).address : latest;

      const locusInstance = await hre.ethers.getContractAt(
        hre.names.internal.diamonds.locusToken.interface,
        locusAddress
      );
      const usersForCalldata = [];
      const stLocusAmountsForCalldata = [];
      const locusAmountsForCalldata = [];
      const usersKeys = Object.keys(incidentData.users);

      for (let i = 0; i < usersKeys.length; i++) {
        const user = usersKeys[i];
        const balance = hre.ethers.utils.parseEther(incidentData.users[user].actualBalanceAtPreErrorBlock);
        const earned = hre.ethers.utils.parseEther(incidentData.users[user].actualEarnedAtPreErrorBlock);
        const locusBalance = hre.ethers.utils.parseEther(incidentData.users[user].actualLocusBalanceAtPreError);
        const amount = balance.add(earned);
        if (amount.eq(0)) continue;
        usersForCalldata.push(user);
        stLocusAmountsForCalldata.push(amount);
        locusAmountsForCalldata.push(locusBalance);
      }

      const totalStaked = hre.ethers.utils.parseEther(incidentData.globalStats.totalStakedAtPreError);
      const totalEarned = hre.ethers.utils.parseEther(incidentData.globalStats.totalEarnedAtPreError);
      const totalStakedAndEarned = totalStaked.add(totalEarned);

      const actualOldStakingBalance = await locusInstance.balanceOf(oldStakingAddress);
      const additionalMintToDistributeToUsers = totalStakedAndEarned.sub(actualOldStakingBalance);

      if (initialOffset === 0) {
        console.log(`WARNING: initialOffset === 0, hence minting additional locuses to the old staking in amount of: ${additionalMintToDistributeToUsers.toString()}`);
        const mintTx = await locusInstance.mint(oldStakingAddress, additionalMintToDistributeToUsers);
        await mintTx.wait(confirmations);
      }

      const parts = 10;
      let groupsCleared = 0;
      console.log(`Users to liquidate incident for: ${usersForCalldata.length}`);
      let window = Math.floor(usersForCalldata.length / parts) + 1;
      console.log(`Groupings of users: ${parts} parts of ${window} users each.`);
      for (let offset = initialOffset; offset < usersForCalldata.length; offset += window) {
        const start = offset;
        let end = start + window;
        if (end > usersForCalldata.length) end = usersForCalldata.length;
        console.log(`Liquidating the incident consequences for a group of users numbered from ${start} to ${end}.`);
        const usersPart = usersForCalldata.slice(start, end);
        const stLocusAmountsPart = stLocusAmountsForCalldata.slice(start, end);
        const locusAmountsPart = locusAmountsForCalldata.slice(start, end);
        const liquidateIncidentTx = await locusInstance.liquidateIncident(
          oldStakingAddress,
          newStakingAddress,
          usersPart,
          stLocusAmountsPart,
          locusAmountsPart
        );
        await liquidateIncidentTx.wait(confirmations);
        groupsCleared++
        console.log(`Group ${start}-${end} under number ${groupsCleared} has been cleared.`);
      }
    });
