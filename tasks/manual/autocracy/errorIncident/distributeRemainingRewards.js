const { types } = require("hardhat/config");
const fsExtra = require("fs-extra");

module.exports = (task) =>
  task(
    "distributeRemainingRewards",
    "Migrates the balances both of classic LOCUS\' and of the old Locus Staking to the new Autoreflective Locus Staking via force burn and mint of LOCUS\'.",
  )
    .addOptionalParam("undistributedReward", "Define undistributed reward amount to be distributed.", '20856.918237199211720795', types.string)
    .addOptionalParam("locus", "Define a name or address of LOCUS token contract in hre.names.", '', types.string)
    .addOptionalParam("jsonWithoutLuckies", "A json data piece of users to migrate balances for.", './resources/json/errorIncident/stLocusHoldersDataForIncidentAnalysisWithoutLuckies.json', types.string)
    .addOptionalParam("confirmations", "An amount of confirmations to wait each iteration of incident liquidation.", 10, types.int)
    .addOptionalParam("parts", "An amount of parts to split users.", 10, types.int)
    .addOptionalParam("initialOffset", "An offset for realigning the group processing.", 0, types.int)
    .setAction(async ({ locus, jsonWithoutLuckies, confirmations, initialOffset, undistributedReward, parts }, hre) => {
      await hre.names.gather();
      if (initialOffset > 0) {
        console.log(`WARNING: groups numeration would be from 0! Set up initial offset: ${initialOffset}`);
      }

      const incidentData = await fsExtra.readJSON(jsonWithoutLuckies);
      const locusAddress = locus !== '' ? locus : (await hre.deployments.get(hre.names.internal.diamonds.locusToken.proxy)).address

      const locusInstance = await hre.ethers.getContractAt(
        hre.names.internal.diamonds.locusToken.interface,
        locusAddress
      );
      const usersForCalldata = [];
      const amountsToMintForCalldata = [];
      const usersKeys = Object.keys(incidentData.users);
      const formattedTotalSupply = parseFloat(incidentData.globalStats.totalStakedAtPreError);
      const formattedUndistributedReward = parseFloat(undistributedReward);

      for (let i = 0; i < usersKeys.length; i++) {
        const user = usersKeys[i];
        const balance = hre.ethers.utils.parseEther(incidentData.users[user].actualBalanceAtPreErrorBlock);
        if (balance.eq(0)) continue;
        usersForCalldata.push(user);
        const formattedBalance = parseFloat(hre.ethers.utils.formatEther(balance));
        const locusAmountToMint = hre.ethers.utils.parseEther(
          ((formattedBalance / formattedTotalSupply) * formattedUndistributedReward).toFixed(18)
        );
        amountsToMintForCalldata.push(locusAmountToMint);
      }
      
      let groupsCleared = 0;
      console.log(`Users to mint undistributed reward part for: ${usersForCalldata.length}`);
      let window = Math.floor(usersForCalldata.length / parts) + 1;
      console.log(`Groupings of users: ${parts} parts of ${window} users each.`);
      for (let offset = initialOffset; offset < usersForCalldata.length; offset += window) {
        const start = offset;
        let end = start + window;
        if (end > usersForCalldata.length) end = usersForCalldata.length;
        console.log(`Minting the undistributed reward part for a group of users numbered from ${start} to ${end}.`);
        const usersPart = usersForCalldata.slice(start, end);
        const locusAmountsToMintPart = amountsToMintForCalldata.slice(start, end);
        const massMintTx = await locusInstance.massMint(
          usersPart,
          locusAmountsToMintPart
        );
        await massMintTx.wait(confirmations);
        groupsCleared++
        console.log(`Group ${start}-${end} under number ${groupsCleared} has been cleared.`);
      }
    });
