module.exports = (
  isReconfigurationRequired,
  tokenAddressOrNameAction,
) => async ({
  getNamedAccounts,
  deployments,
  network
}) => {
    if (!hre.names.isInitialized()) {
      await hre.names.gather();
    }
    const { diamond, get } = deployments;
    const { deployer } = await getNamedAccounts();

    const tokenAddressOrName = tokenAddressOrNameAction();

    const facets = [
      "RolesManagementFacet",
      "TDLoupeFacet",
      "TDManagementFacet",
      "TDProcessFacet",
      "LSSendingsDequeFacet",
      "LSSendingsDequeLoupeFacet",
      "ASInitializerFacet",
      "ASDepositaryFacet",
      "ASEip20Facet",
      "ASReflectionFacet",
      "ASReflectionLoupeFacet",
      "ASFeeAdvisorFacet"
    ];

    const libraries = [
      'ASLib',
      'InitializerLib',
      'RolesManagementLib',
      'TDLib',
      'DelayedSendingsQueueLib'
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
        args: [
          deployer,
          tokenAddressOrName.startsWith("0x") 
            ? tokenAddressOrName 
            : (await get(tokenAddressOrName)).address
        ]
      };
    }
    
    await diamond.deploy("AutoreflectiveStaking", diamondDeployConfig);
  }