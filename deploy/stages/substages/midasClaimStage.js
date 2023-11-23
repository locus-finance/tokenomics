const hre = require('hardhat');
const { skipIfAlreadyDeployed } = require('../../helpers');

module.exports = async ({
  getNamedAccounts,
  deployments,
  network
}) => {
  const { deploy, get, execute } = deployments;
  const { deployer } = await getNamedAccounts();
}
module.exports.tags = ["midasClaimStage", "claim"];
