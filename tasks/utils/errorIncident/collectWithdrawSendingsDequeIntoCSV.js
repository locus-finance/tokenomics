const { types } = require("hardhat/config");
const fsExtra = require("fs-extra");
module.exports = (task) =>
  task(
    "collectSendings",
    "Collects sendings from JSON data into CSV table..",
  )
    .addOptionalParam("json", "File name of JSON data of withdraws deque.", './resources/json/errorIncident/withdrawsDequePreError.json', types.string)
    .addOptionalParam("csv", "File name of CSV where the JSON data of the deque will be stored.", './resources/csv/errorIncident/withdrawsDequePreError.csv', types.string)
    .setAction(async ({ json, csv }, hre) => {
        let csvString = "\"receiver\",\"amount\",\"dueToTimestamp\",\"dueToDurationCode\"\n";
        const sendingsData = await fsExtra.readJSON(json);
        for (let i = 0; i < sendingsData.length; i++) {
            csvString += `\"${sendingsData[i].receiver}\",${sendingsData[i].amount},${sendingsData[i].dueToTimestamp},${sendingsData[i].dueToDuration}\n`;
        }
        await fsExtra.outputFile(csv, csvString);
        console.log(`Source JSON data of withdrawals deque: ${json}`);
        console.log(`CSV table stored in: ${csv}`);
    });
