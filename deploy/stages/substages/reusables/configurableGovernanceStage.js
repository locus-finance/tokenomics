const hre = require('hardhat');

module.exports = (
  isReconfigurationRequired
) => async ({
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

    let locusAddress;
    if (isReconfigurationRequired) {
      locusAddress = (await get(hre.names.internal.diamonds.locusToken.proxy)).address;
    }

    let diamondDeployConfig = {
      from: deployer,
      facets,
      log: true,
      libraries
    };

    if (isReconfigurationRequired) {
      diamondDeployConfig['execute'] = {
        methodName: 'initialize',
        args: [
          locusAddress,
          0,
          0,
          1,
          1
        ]
      };
    }
    
    await diamond.deploy('LocusGovernor', diamondDeployConfig);
  }
 