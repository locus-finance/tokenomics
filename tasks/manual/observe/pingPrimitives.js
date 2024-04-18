const { types } = require("hardhat/config");
module.exports = (task) =>
  task(
    "primitives",
    "Get current primitives.",
  )
    .addOptionalParam("staking", "Define a name of staking contract in hre.names.", '', types.string)
    .setAction(async ({ staking }, hre) => {
      await hre.names.gather();
      staking = staking !== '' ? staking : hre.names.internal.diamonds.locusStaking.proxy;
      const stakingInstance = await hre.ethers.getContractAt(
        hre.names.internal.diamonds.locusStaking.interface,
        (await hre.deployments.get(staking)).address
      );
      let result = await stakingInstance.getPrimitives();
      console.log(`Primitives:`);
      console.log(result);
    });
