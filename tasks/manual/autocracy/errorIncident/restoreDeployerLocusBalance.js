const { types } = require("hardhat/config");
const fsExtra = require("fs-extra");

module.exports = (task) =>
  task(
    "restoreDeployerLocusBalance",
    "Restore deployers balance of LOCUS\' after the incident liquidation.",
  )
    .addOptionalParam("locus", "Define a name or address of LOCUS token contract in hre.names.", '', types.string)
    .addOptionalParam("jsonWithoutLuckies", "A json data piece of users to migrate balances for.", './resources/json/errorIncident/stLocusHoldersDataForIncidentAnalysisWithoutLuckies.json', types.string)
    .addOptionalParam("jsonWithLuckies", "A json data piece of users to migrate balances for.", './resources/json/errorIncident/stLocusHoldersDataForIncidentAnalysisWithLuckies.json', types.string)
    .addOptionalParam("confirmations", "An amount of confirmations to wait for minting.", 10, types.int)
    .setAction(async ({ locus, jsonWithoutLuckies, jsonWithLuckies }, hre) => {
      await hre.names.gather();
      const { getNamedAccounts } = hre;
      const { deployer } = await getNamedAccounts();
      const incidentDataWithLuckies = await fsExtra.readJSON(jsonWithLuckies);
      const incidentData = await fsExtra.readJSON(jsonWithoutLuckies);
      const locusAddress = locus !== '' ? locus : (await hre.deployments.get(hre.names.internal.diamonds.locusToken.proxy)).address
      const locusInstance = await hre.ethers.getContractAt(
        hre.names.internal.diamonds.locusToken.interface,
        locusAddress
      );
      const balanceOfStakingContractInLocusAtPreError = hre.ethers.utils.parseEther(incidentData.globalStats.balanceOfStakingContractInLocusAtPreError);
      const totalStaked = hre.ethers.utils.parseEther(incidentData.globalStats.totalStakedAtPreError);
      const totalEarned = hre.ethers.utils.parseEther(incidentData.globalStats.totalEarnedAtPreError);
      const differenceInIncidentDataWithLuckies = hre.ethers.utils.parseEther(incidentDataWithLuckies.globalStats.difference);
      const differenceInIncidentDataWithoutLuckies = hre.ethers.utils.parseEther(incidentData.globalStats.difference);
      const totalStakedAndEarned = totalStaked.add(totalEarned);
      const luckiesBalances = differenceInIncidentDataWithoutLuckies.sub(differenceInIncidentDataWithLuckies);
      const expectedAutocratBalance = balanceOfStakingContractInLocusAtPreError.sub(totalStakedAndEarned).sub(luckiesBalances);
      console.log(`Calculated amount to be minted to the deployer: ${hre.ethers.utils.formatEther(expectedAutocratBalance)}`);
      const mintTx = await locusInstance.mint(deployer, expectedAutocratBalance);
      await mintTx.wait(confirmations);
      console.log('Minting has done.')
    });
