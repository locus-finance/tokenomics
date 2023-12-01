const { types } = require("hardhat/config");
module.exports = (task) =>
  task(
    "updateMerkleTree",
    "Updates MerkleTree of MidasClaim by reloading info from csv.",
  )
    .addOptionalParam("pathToCsv", "Define a path to csv where the MerkleTree body is stored.", './resources/csv/midasHoldersSnapshot.csv', types.string)
    .setAction(async ({ pathToCsv }, hre) => {
      const { merkleTree } = await hre.run("getMerkleTreeInfo", {
        path: pathToCsv
      });
      const signers = await hre.ethers.getSigners();
      const deployer = signers[0].address;
      await hre.deployments.execute(
        hre.names.internal.midasClaim,
        {from: deployer, log: true},
        'setNewMerkleRoot',
        merkleTree.root
      );
      console.log(`New MerkleTree root is set: ${merkleTree.root}`);
    });
