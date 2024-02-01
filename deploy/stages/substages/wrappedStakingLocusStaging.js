const hre = require('hardhat');
const { 
  skipIfAlreadyDeployed, 
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

  await deploy(hre.names.internal.wrappedStakingLocus, {
    from: deployer,
    skipIfAlreadyDeployed,
    log: true,
    args: [
        locusStaking,
        locusAddress
    ]
  });
}
module.exports.tags = ["wrappedStakingLocusStage", "stLOCUS"];
