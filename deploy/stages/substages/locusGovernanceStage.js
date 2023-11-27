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
    "LGGovernorFacet",
    "LGInitializerFacet",
  ];

  const libraries = [
    'LGLib',
    'InitializerLib',
    'PausabilityLib',
    'RolesManagementLib',
  ];

  const locusAddress = (await get(hre.names.internal.diamonds.locusToken.proxy)).address;

  await diamond.deploy('LocusGovernor', {
    from: deployer,
    facets,
    log: true,
    libraries
  });

  await execute(
    hre.names.internal.diamonds.locusGovernor.proxy,
    {from: deployer, log: true},
    'initialize',
    locusAddress,
    0,
    0,
    1,
    1
  );
}
module.exports.tags = ["locusGovernanceStage", "governance"];
