const hre = require('hardhat');

module.exports = (
  isReconfigurationRequired
) => async ({
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

  let diamondDeployConfig = {
    from: deployer,
    facets,
    log: true,
    libraries
  };

  if (isReconfigurationRequired) {
    diamondDeployConfig['execute'] = {
      methodName: 'initialize',
      args: [deployer]
    };
  }

  await diamond.deploy('LocusToken', diamondDeployConfig);

  if (isReconfigurationRequired) {
    await execute(
      hre.names.internal.diamonds.locusToken.proxy,
      { from: deployer, log: true },
      'setupTokenInfoAndEstablishAutocracy'
    );
  }
}