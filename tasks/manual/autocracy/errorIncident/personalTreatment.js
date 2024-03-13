const { types } = require("hardhat/config");
const fsExtra = require("fs-extra");

module.exports = (task) =>
  task(
    "personalTreatment",
    "Treats personally the situation of luckies.",
  )
    .addOptionalParam("locus", "Define a name or address of LOCUS token contract in hre.names.", '', types.string)
    .addOptionalParam("lucky", "An address of the lucky one.", '', types.string)
    .addOptionalParam("jsonWithLuckies", "A json data piece of users to migrate balances for.", './resources/json/errorIncident/stLocusHoldersDataForIncidentAnalysisWithLuckies.json', types.string)
    .addOptionalParam("confirmations", "An amount of confirmations to wait each iteration of incident liquidation.", 10, types.int)
    .addOptionalParam("lessThenTimes", "Times for how many the users sold amount should be less then to burn their locuses.", 100, types.int)
    .setAction(async ({ locus, jsonWithLuckies, confirmations, lucky, lessThenTimes }, hre) => {
      await hre.names.gather();
      const locusAddress = locus !== '' ? locus : (await hre.deployments.get(hre.names.internal.diamonds.locusToken.proxy)).address
      const locusInstance = await hre.ethers.getContractAt(
        hre.names.internal.diamonds.locusToken.interface,
        locusAddress
      );
      const incidentDataWithLuckies = await fsExtra.readJSON(jsonWithLuckies);
      
      const personalTreatmentTx = await locusInstance.personalTreatment(
        lucky,
        incidentDataWithLuckies.luckiesInfo[lucky].expectedBalance,
        incidentDataWithLuckies.luckiesInfo[lucky].soldAmount,
        lessThenTimes
      );
      await personalTreatmentTx.wait(confirmations);
      console.log(`Personal treatment executed for: ${lucky}.\nTheir current balance is: ${hre.ethers.utils.formatEther(await locusInstance.balanceOf(lucky))}`);
    });
