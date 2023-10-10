const hre = require('hardhat');

module.exports =
  () => async (deployScriptParams) => {
    const {
      getNamedAccounts,
      deployments
    } = deployScriptParams;

    const { log, get } = deployments;
    const { deployer } = await getNamedAccounts();
    log('Some reusable stage mock.');
  }