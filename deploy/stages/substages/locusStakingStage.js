const hre = require('hardhat');

module.exports = async ({
  getNamedAccounts,
  deployments,
  network
}) => {
  const { diamond, get } = deployments;
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

  const locusAddress = (await get(hre.names.internal.diamonds.locusToken.proxy)).address;

  await diamond.deploy('LocusStaking', {
    from: deployer,
    facets,
    log: true,
    libraries,
    execute: {
      methodName: 'initialize',
      args: [
        deployer,
        locusAddress,
        deployer,
        locusAddress,
        locusAddress,
        [],
        []
      ]
    }
  });
}
module.exports.tags = ["locusStakingStage", "staking"];
