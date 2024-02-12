const hre = require('hardhat');
const { skipIfAlreadyDeployed } = require('../helpers');

module.exports = async ({
  getNamedAccounts,
  deployments
}) => {
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();
  await deploy(hre.names.internal.mockLocus, {
    from: deployer,
    skipIfAlreadyDeployed,
    args: [
      deployer
    ],
    log: true
  });
  await deployments.execute(
    hre.names.internal.mockLocus,
    {from: deployer, log: true},
    "mint",
    deployer,
    hre.ethers.utils.parseEther("1000000000")
  );
}
module.exports.tags = ["mockLocus"];
