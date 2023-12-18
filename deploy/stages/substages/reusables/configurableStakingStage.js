const hre = require('hardhat');
module.exports = (
  stakingContractName,
  isReconfigurationRequired
) => async ({
  getNamedAccounts,
  deployments,
  network
}) => {
    const { diamond, get, execute } = deployments;
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
      "LSProcessFeesFacet",
      "LSSendingsDequeFacet",
      "LSSendingsDequeLoupeFacet"
    ];

    const libraries = [
      'TDLib',
      'LSLib',
      'InitializerLib',
      'RolesManagementLib',
      'DelayedSendingsQueueLib'
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
          deployer,
          locusAddress,
          deployer,
          locusAddress,
          locusAddress,
          [],
          []
        ]
      };
    }
    
    await diamond.deploy(`${stakingContractName}Staking`, diamondDeployConfig);

    if (isReconfigurationRequired) {
      await execute(
        hre.names.internal.diamonds.locusStaking.proxy,
        { from: deployer, log: true },
        'prepareDepositary'
      );
    }
  }