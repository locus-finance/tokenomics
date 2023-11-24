const hre = require('hardhat');

module.exports = async ({
  getNamedAccounts,
  deployments
}) => {
  const { diamond, execute } = deployments;
  const { deployer } = await getNamedAccounts();

  const facets = [
    "RolesManagementFacet",
    "TDLoupeFacet",
    "TDManagementFacet",
    "TDProcessFacet",
    "LTERC20Facet",
    "LTEmissionControlFacet",
    "LTAutocracyFacet",
    "LTInitializerFacet"
  ];

  const libraries = [
    'TDLib',
    'LTLib',
    'InitializerLib',
    'PausabilityLib',
    'RolesManagementLib',
    'AutocracyLib'
  ];

  await diamond.deploy('LocusToken', {
    from: deployer,
    facets,
    log: true,
    libraries,
    execute: {
      methodName: 'initialize',
      args: [deployer]
    }
  });

  await execute(
    hre.names.internal.diamonds.locusToken.proxy,
    {from: deployer, log: true},
    'setupTokenInfoAndEstablishAutocracy'
  );
}
module.exports.tags = ["locusTokenStage", "token"];
