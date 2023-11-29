const { types } = require("hardhat/config");
const fsExtra = require('fs-extra');
module.exports = (task) =>
  task(
    "generateJsonOfMerkleTreeBody",
    "Generate JSON of Merkle Tree body of addresses and balances.",
  )
    .addOptionalParam("pathToCsv", "Define a path to csv where the MerkleTree body is stored.", './resources/csv/midasHoldersSnapshot.csv', types.string)
    .addOptionalParam("path", "Define a path to json where the MerkleTree body would be stored.", './midasMerkleTreeBody.json', types.string)
    .setAction(async ({ path, pathToCsv }, hre) => {
      const merkleTreeInfo = await hre.run("getMerkleTreeInfo", {
        path: pathToCsv
      });
      console.log(`JSON ready to be written:\n${JSON.stringify(merkleTreeInfo.merkleTreeBody)}`);
      await fsExtra.writeJSON(path, merkleTreeInfo.merkleTreeBody)
    });
