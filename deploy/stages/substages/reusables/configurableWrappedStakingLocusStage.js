const hre = require('hardhat');
const {
  skipIfAlreadyDeployed,
} = require('../../../helpers');

module.exports = (
  stakingDiamondNameAction,
  locusDiamondNameAction,
  isForceRedeployRequested
) => async ({
  getNamedAccounts,
  deployments
}) => {
    if (!hre.names.isInitialized()) {
      await hre.names.gather();
    }
    const stakingDiamondName = stakingDiamondNameAction();
    const locusDiamondName = locusDiamondNameAction();
    const { deploy, get, execute } = deployments;
    const { deployer } = await getNamedAccounts();

    const locusAddress = (await get(locusDiamondName)).address;
    const locusStaking = (await get(stakingDiamondName)).address;

    await deploy(hre.names.internal.wrappedStakingLocus, {
      from: deployer,
      skipIfAlreadyDeployed: isForceRedeployRequested !== undefined ? isForceRedeployRequested : skipIfAlreadyDeployed,
      log: true,
      args: [
        locusStaking,
        locusAddress
      ]
    });

    await execute(
      stakingDiamondName,
      { from: deployer, log: true },
      'setWrappedStakingLocus',
      (await get(hre.names.internal.wrappedStakingLocus)).address
    );
  }
