const hre = require('hardhat');

module.exports = async ({
  getNamedAccounts,
  deployments,
  network
}) => {
  const { deploy, get, execute } = deployments;
  const { deployer } = await getNamedAccounts();

  // const diamondInstance = await hre.ethers.getContractAt(
  //   hre.names.internal.diamonds.locusToken.interface,
  //   (await get(hre.names.internal.diamonds.locusToken.proxy)).address
  // );

  // // const initTx = await diamondInstance.initialize(deployer);
  // // await initTx.wait();
}
module.exports.tags = ["locusStakingStage", "staking"];
