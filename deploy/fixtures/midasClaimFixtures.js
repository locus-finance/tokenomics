const hre = require('hardhat');
const { skipIfAlreadyDeployed, getMockTree } = require('../helpers');

module.exports = async ({
  getNamedAccounts,
  deployments
}) => {
  const { deploy, get } = deployments;
  const { deployer, treasury, user1, user2 } = await getNamedAccounts();
  await deploy(hre.names.internal.mockLocus, {
    from: deployer,
    skipIfAlreadyDeployed,
    args: [
      deployer
    ],
    log: true
  });
  await deploy(hre.names.internal.mockStaking, {
    from: deployer,
    skipIfAlreadyDeployed,
    args: [
      (await get(hre.names.internal.mockLocus)).address
    ],
    log: true
  });

  await deploy(hre.names.internal.midasClaim, {
    from: deployer,
    skipIfAlreadyDeployed,
    args: [
      (await deployments.get(hre.names.internal.mockLocus)).address,
      (await deployments.get(hre.names.internal.mockStaking)).address,
      getMockTree(user1, user2).root,
      treasury
    ],
    log: true
  });

  await deployments.execute(
    hre.names.internal.mockLocus,
    {from: deployer, log: true},
    "mint",
    (await deployments.get(hre.names.internal.midasClaim)).address,
    hre.ethers.utils.parseEther("1000000000")
  );
}
module.exports.tags = ["midasClaimFixtures"];
