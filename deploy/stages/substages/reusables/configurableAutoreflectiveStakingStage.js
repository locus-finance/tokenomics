const hre = require('hardhat');
module.exports = (
  initialRewardAmount,
  stakingContractName,
  isReconfigurationRequired,
  stakingTokenAddressOrNameAction,
  rewardTokenAddressOrNameAction
) => async ({
  getNamedAccounts,
  deployments,
  network
}) => {
    const { diamond, get, execute, log } = deployments;
    const { deployer } = await getNamedAccounts();

    const stakingTokenAddressOrName = stakingTokenAddressOrNameAction();
    const rewardTokenAddressOrName = rewardTokenAddressOrNameAction();

    const facets = [
      "RolesManagementFacet",
      "ASInitializerFacet",
      "ASDepositaryFacet",
      "ASEip20Facet",
      "ASReflectionFacet",
      "ASReflectionLoupeFacet"
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
          initialRewardAmount,
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