module.exports = (
  isReconfigurationRequired,
  stakingTokenAddressOrNameAction,
  rewardTokenAddressOrNameAction
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

    const stakingTokenAddressOrName = stakingTokenAddressOrNameAction();
    const rewardTokenAddressOrName = rewardTokenAddressOrNameAction();

    const facets = [
      "RolesManagementFacet",
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
      'RolesManagementLib'
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
          stakingTokenAddressOrName.startsWith("0x") 
            ? stakingTokenAddressOrName 
            : (await get(stakingTokenAddressOrName)).address,
          rewardTokenAddressOrName.startsWith("0x") 
            ? rewardTokenAddressOrName 
            : (await get(rewardTokenAddressOrName)).address
        ]
      };
    }
    
    await diamond.deploy("AutoreflectiveStaking", diamondDeployConfig);
  }