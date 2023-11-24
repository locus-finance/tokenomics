const hre = require('hardhat');

module.exports = async ({
  getNamedAccounts,
  deployments,
  network
}) => {
  const { deploy, get, execute } = deployments;
  const { deployer } = await getNamedAccounts();
}
module.exports.tags = ["midasClaimStage", "claim"];
