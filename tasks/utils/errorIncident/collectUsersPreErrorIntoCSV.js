const { types } = require("hardhat/config");
const fsExtra = require("fs-extra");
module.exports = (task) =>
  task(
    "collectUsersPreErrorIntoCSV",
    "Collects users from JSON data into CSV table..",
  )
    .addOptionalParam("json", "File name of JSON data of users.", './resources/json/errorIncident/stLocusHoldersDataForIncidentAnalysisWithLuckies.json', types.string)
    .addOptionalParam("csv", "File name of CSV where the JSON data of the deque will be stored.", './resources/csv/errorIncident/stLocusHoldersDataForIncidentAnalysisWithLuckies.csv', types.string)
    .setAction(async ({ json, csv }, hre) => {
        let csvString = "\"receiver\",\"stLocusAmount\",\"earnedStLocusAmount\"\n";
        const usersData = (await fsExtra.readJSON(json)).users;
        for (const user of Object.keys(usersData)) {
            csvString += `\"${usersData[user].address}\",${usersData[user].actualBalanceAtPreErrorBlock},${usersData[user].actualEarnedAtPreErrorBlock}\n`;
        }
        await fsExtra.outputFile(csv, csvString);
        console.log(`Source JSON data of users: ${json}`);
        console.log(`CSV table stored in: ${csv}`);
    });
