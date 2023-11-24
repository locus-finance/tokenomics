const hre = require('hardhat');

module.exports = async ({
  getNamedAccounts,
  deployments,
  network
}) => {
  const { deploy, get, execute } = deployments;
  const { deployer } = await getNamedAccounts();

  const facets = [
    "RolesManagementFacet",
    "TDLoupeFacet",
    "TDManagementFacet",
    "TDProcessFacet",
    "LSDepositaryFacet",
    "LSERC20Facet",
    "LSInitializerFacet",
    "LSLoupeFacet",
    "LSManagementFacet",
    "LSProcessFeesFacet"
  ];

  const libraries = [
    'TDLib',
    'LSLib',
    'InitializerLib',
    'PausabilityLib',
    'RolesManagementLib',
  ];

  await diamond.deploy('LocusStaking', {
    from: deployer,
    facets,
    log: true,
    libraries,
    execute: {
      methodName: 'initialize',
      args: [deployer]
    }
  });
}
module.exports.tags = ["locusStakingStage", "staking"];
