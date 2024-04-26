const hre = require('hardhat');

module.exports = (
  isReconfigurationRequired
) => async ({
  getNamedAccounts,
  deployments
}) => {
  if (!hre.names.isInitialized()) {
    await hre.names.gather();
  }
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
    "LTAutocracyGovernmentFacet",
    "LTInitializerFacet"
  ];

  const libraries = [
    'TDLib',
    'LTLib',
    'InitializerLib',
    'PausabilityLib',
    'RolesManagementLib',
    'AutocracyLib',
    'AutocracyGovernmentLib'
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