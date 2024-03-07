const hre = require('hardhat');
const { skipIfAlreadyDeployed } = require('../helpers');
const configurableAutoreflectiveStakingStage = require("../stages/substages/reusables/configurableAutoreflectiveStakingStage");

module.exports = async (deployContext) => {
  const {
    getNamedAccounts,
    deployments
  } = deployContext;
  await hre.names.gather();
  const { deploy, execute, get } = deployments;
  const { deployer } = await getNamedAccounts();

  const initialRewardAmount = hre.ethers.utils.parseEther('32500');

  // await deploy(hre.names.internal.mockLocus, {
  //   from: deployer,
  //   skipIfAlreadyDeployed,
  //   args: [
  //     deployer
  //   ],
  //   log: true
  // });
  
  await configurableAutoreflectiveStakingStage(
    false,
    () => hre.names.internal.mockLocus
  )(deployContext);
  
  // await execute(
  //   hre.names.internal.mockLocus,
  //   {from: deployer, log: true},
  //   "mint",
  //   deployer,
  //   initialRewardAmount
  // );

  const staking = await hre.ethers.getContractAt(
    "DiamondAutoreflectiveStaking",
    (await get("AutoreflectiveStaking_DiamondProxy")).address
  );
  const initTx = await staking.tempInit((await get("MockLocus")).address);
  await initTx.wait();
  console.log(JSON.stringify(initTx));
}
module.exports.tags = ["autoreflectiveStakingFixture"];
