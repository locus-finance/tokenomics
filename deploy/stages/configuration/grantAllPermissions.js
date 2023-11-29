const hre = require('hardhat');
const keccak256 = require('keccak256');

module.exports = async ({
  getNamedAccounts,
  deployments,
  network
}) => {
  const { log, execute, get } = deployments;
  const { deployer } = await getNamedAccounts();
  await execute(
    hre.names.internal.diamonds.locusStaking.proxy,
    {from: deployer, log: true},
    'grantRole',
    (await get(hre.names.internal.midasClaim)).address,
    keccak256('ALLOWED_TO_STAKE_FOR_ROLE')
  );
  await execute(
    hre.names.internal.diamonds.locusToken.proxy,
    {from: deployer, log: true},
    'grantRole',
    (await get(hre.names.internal.diamonds.locusStaking.proxy)).address,
    keccak256('ALLOWANCE_FREE_ROLE')
  );
  log(`permissions are granted`);
}
module.exports.tags = ["grantAllPermissions", "permissions"];
