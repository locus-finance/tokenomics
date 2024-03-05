const hre = require('hardhat');
const keccak256 = require('keccak256');

module.exports = async ({
  getNamedAccounts,
  deployments,
  network
}) => {
  if (!hre.names.isInitialized()) {
    await hre.names.gather();
  }
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
  await execute(
    hre.names.internal.diamonds.locusStaking.proxy,
    {from: deployer, log: true},
    'grantRole',
    deployer,
    keccak256('DELAYED_SENDINGS_QUEUE_PROCESSOR_ROLE')
  );

  const xUSDStaking = await hre.ethers.getContractAt(
    hre.names.internal.diamonds.locusXEthTokensStaking.interface,
    (await get(hre.names.internal.diamonds.locusXEthTokensStaking.proxy)).address
  );
  const grantRoleTx = await xUSDStaking.grantRole(
    (await get(hre.names.external.backendDeveloper)).address,
    keccak256('REWARD_DISTRIBUTOR_ROLE')
  );
  await grantRoleTx.wait();
  log(`Grant role: ${hre.names.internal.diamonds.locusXEthTokensStaking.interface}\n${JSON.stringify(grantRoleTx)}`);

  const locusStaking = await hre.ethers.getContractAt(
    hre.names.internal.diamonds.locusStaking.interface,
    (await get(hre.names.internal.diamonds.locusStaking.proxy)).address
  );
  const grantRoleLocusStakingTx = await locusStaking.grantRole(
    (await get(hre.names.external.backendDeveloper)).address,
    keccak256('REWARD_DISTRIBUTOR_ROLE')
  );
  await grantRoleLocusStakingTx.wait();
  log(`Grant role: ${hre.names.internal.diamonds.locusStaking.interface}\n${JSON.stringify(grantRoleLocusStakingTx)}`);

  log(`permissions are granted`);
}
module.exports.tags = ["grantAllPermissions", "permissions"];
