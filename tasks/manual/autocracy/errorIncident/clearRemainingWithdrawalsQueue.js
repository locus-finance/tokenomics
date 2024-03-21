const { types } = require("hardhat/config");
const { parseCSV } = require('../../../../deploy/helpers');
const fsExtra = require("fs-extra");

module.exports = (task) =>
  task(
    "clearRemainingWithdrawalsQueue",
    "Clears remaining deque of withdrawals of LOCUS\' from the old staking.",
  )
    .addOptionalParam("treasury", "Define an address of the fees treasury.", '0xf4bEC3e032590347Fc36AD40152C7155f8361d39', types.string)
    .addOptionalParam("locus", "Define a name or address of LOCUS token contract in hre.names.", '', types.string)
    .addOptionalParam("csv", "A csv data of remaining delayed sendings.", './resources/csv/errorIncident/withdrawsDequePostErrorInOldStakingWithoutAlreadyExecuted.csv', types.string)
    .addOptionalParam("confirmations", "An amount of confirmations to wait each iteration of incident liquidation.", 10, types.int)
    .setAction(async ({ locus, csv, confirmations, treasury }, hre) => {
      await hre.names.gather();

      const locusAddress = locus !== '' ? locus : (await hre.deployments.get(hre.names.internal.diamonds.locusToken.proxy)).address

      const locusInstance = await hre.ethers.getContractAt(
        hre.names.internal.diamonds.locusToken.interface,
        locusAddress
      );
      
      const sendings = await parseCSV(["receiver", "amount", "dueToDate", "dueToDurationCode", "cleared"], csv);
      const currentDate = new Date();

      let counter = 0;
      for (let i = 0; i < sendings.length; i++) {
        const sendingsDate = new Date(sendings[i].dueToDate);
        if (sendingsDate.getTime() <= currentDate.getTime() && sendings[i].cleared === "false") {
          console.log(`--- Clearing: ${sendings[i].receiver} - ${sendingsDate.toUTCString()} ---`);
          sendings[i].cleared = "true";
          counter++;
          let amountToMintToReceiver;
          let amountToMintToTreasury;
          const amount = parseFloat(sendings[i].amount);
          switch (sendings[i].dueToDurationCode) {
            case "2":
              amountToMintToTreasury = amount * 3750 / 10000;
              amountToMintToReceiver = amount - amountToMintToTreasury;
              break;
            case "3":
              amountToMintToTreasury = amount * 2500 / 10000;
              amountToMintToReceiver = amount - amountToMintToTreasury;
              break;
            case "4":
              amountToMintToTreasury = 0;
              amountToMintToReceiver = amount - amountToMintToTreasury;
              break;
          }
          const mintTx = await locusInstance.mint(
            sendings[i].receiver,
            hre.ethers.utils.parseEther(amountToMintToReceiver.toFixed())
          )
          await mintTx.wait(confirmations);
          console.log(`Minted for: ${sendings[i].receiver}, tx info:\n${JSON.stringify(mintTx)}`);
          if (amountToMintToTreasury > 0) {
            const mintToTreasuryTx = await locusInstance.mint(
              treasury,
              hre.ethers.utils.parseEther(amountToMintToTreasury.toFixed())
            )
            await mintToTreasuryTx.wait(confirmations);
            console.log(`Minted for treasury: ${sendings[i].receiver}, tx info:\n${JSON.stringify(mintToTreasuryTx)}`);
          } else {
            console.log('Nothing to mint to treasury for the receiver above.');
          }
          console.log(`--- Clearing is done for: ${sendings[i].receiver} ---`);
        }
      }
      console.log(`Total cleared today: ${counter}`);

      let csvString = "\"receiver\",\"amount\",\"dueToDate\",\"dueToDurationCode\",\"cleared\"\n";
      for (let i = 0; i < sendings.length; i++) {
          csvString += `\"${sendings[i].receiver}\",${sendings[i].amount},\"${sendings[i].dueToDate}\",${sendings[i].dueToDurationCode},\"${sendings[i].cleared}\"\n`;
      }
      await fsExtra.outputFile(csv, csvString);
    });
