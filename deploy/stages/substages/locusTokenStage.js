const hre = require('hardhat');
const { manipulateFacet } = require('../../fixtures/utils/helpers');

module.exports = async ({
  getNamedAccounts,
  deployments
}) => {
  const { diamond } = deployments;
  const { deployer } = await getNamedAccounts();

  const execute = {
    methodName: 'initialize',
    args: [
        deployer
    ]
  };
 
  const facets = [
    "RolesManagementFacet",
    "LTEmissionControlFacet",
    "LTAutocracyFacet",
    "LTERC20Facet",
    "LTInitializerFacet"
  ];

  const libraries = [
    'LTLib',
    'InitializerLib',
    'PausabilityLib',
    'RolesManagementLib'
  ];

  await diamond.deploy('LocusToken', {
    from: deployer,
    facets,
    log: true,
    libraries,
    execute
  });

}
module.exports.tags = ["locusTokenStage", "token"];
