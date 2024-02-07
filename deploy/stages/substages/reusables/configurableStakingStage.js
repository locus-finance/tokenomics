const hre = require('hardhat');
module.exports = (
  stakingContractName,
  isReconfigurationRequired,
  stakingTokenAddressOrName
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
      stakingTokenAddressOrName === undefined ? "LSDepositaryFacet" : "LSDepositaryForVaultTokensFacet",
      "LSInitializerFacet",
      "LSLoupeFacet",
      "LSManagementFacet",
      stakingTokenAddressOrName === undefined ? "LSProcessFeesFacet" : "LSProcessFeesForVaultTokensFacet",
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

    const locusToken = (await get(hre.names.internal.diamonds.locusToken.proxy)).address;
    if (isReconfigurationRequired && stakingTokenAddressOrName === undefined) {
      stakingTokenAddressOrName = locusToken;
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
          deployer,
          locusToken,
          stakingTokenAddressOrName.startsWith("0x") 
            ? stakingTokenAddressOrName 
            : (await get(stakingTokenAddressOrName)).address  
        ]
      };
    }
    
    const rawName = `${stakingContractName}Staking`;
    await diamond.deploy(rawName, diamondDeployConfig);

    if (isReconfigurationRequired) {
      await execute(
        hre.names.internal.diamonds[rawName[0].toLowerCase() + rawName.slice(1)].proxy,
        { from: deployer, log: true },
        'prepareDepositary'
      );
    }
  }