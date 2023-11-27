const hre = require('hardhat');
const { 
  skipIfAlreadyDeployed, 
  getFakeDeployment, 
  getMerkleTree, 
  parseCSV
} = require('../../helpers');

module.exports = async ({
  getNamedAccounts,
  deployments,
  network
}) => {
  const { deploy, get } = deployments;
  const { deployer } = await getNamedAccounts();

  const locusAddress = (await get(hre.names.internal.diamonds.locusToken.proxy)).address;
  const locusStaking = (await get(hre.names.internal.diamonds.locusStaking.proxy)).address;

  const addressKey = "HolderAddress";
  const balanceKey = "Balance";

  const parsedMidasSnapshot = await parseCSV(
    [addressKey, balanceKey], "./resources/midasHoldersSnapshot.csv"
  );
  const merkleTreeBody = [];
  for (const entry of parsedMidasSnapshot) {
    merkleTreeBody.push([
      entry[addressKey],
      hre.ethers.utils.parseEther(
        entry[balanceKey].includes(",") 
          ? entry[balanceKey].replace(",", "") 
          : entry[balanceKey]
      ).toString()
    ]);
  }
  const merkleTree = getMerkleTree(merkleTreeBody);

  await deploy(hre.names.internal.midasClaim, {
    from: deployer,
    skipIfAlreadyDeployed,
    log: true,
    args: [
      locusAddress,
      locusStaking,
      merkleTree.root,
      deployer
    ]
  });
}
module.exports.tags = ["midasClaimStage", "claim"];
