const hre = require('hardhat');
const { skipIfAlreadyDeployed } = require('../helpers');

module.exports = async ({
  getNamedAccounts,
  deployments
}) => {
  const { deploy, get } = deployments;
  const { deployer, user1 } = await getNamedAccounts();
  await deploy(hre.names.internal.mockLocus, {
    from: deployer,
    skipIfAlreadyDeployed,
    args: [
      deployer
    ],
    log: true
  });
}
module.exports.tags = ["autoreflectiveStakingFixture"];
