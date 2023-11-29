const hre = require('hardhat');
const { WEEK, MONTH } = require('../../helpers');

module.exports = async ({
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
    "LSProcessFeesFacet"
  ];

  const libraries = [
    'TDLib',
    'LSLib',
    'InitializerLib',
    'RolesManagementLib',
  ];

  // const locusAddress = (await get(hre.names.internal.diamonds.locusToken.proxy)).address;

  await diamond.deploy('LocusStaking', {
    from: deployer,
    facets,
    log: true,
    libraries,
    // execute: {
    //   methodName: 'initialize',
    //   args: [
    //     deployer,
    //     locusAddress,
    //     deployer,
    //     locusAddress,
    //     locusAddress,
    //     [WEEK, 2 * WEEK, MONTH, MONTH + 1],
    //     [5000, 3750, 2500, 0]
    //   ]
    // }
  });

  // await execute(
  //   hre.names.internal.diamonds.locusStaking.proxy,
  //   {from: deployer, log: true},
  //   'prepareDepositary'
  // );
}
module.exports.tags = ["locusStakingStage", "staking"];
