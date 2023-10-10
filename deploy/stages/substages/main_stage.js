const hre = require('hardhat');
const { skipIfAlreadyDeployed, POOL_DEPLOY_COST } = require('../../helpers');

module.exports = async ({
  getNamedAccounts,
  deployments,
  network
}) => {
  const { deploy, get, execute } = deployments;
  const { deployer } = await getNamedAccounts();
}
module.exports.tags = ["main_stage", "main"];
