const { types } = require("hardhat/config");
module.exports = (task) =>
  task(
    "reward",
    "Call getReward(...) on staking contract.",
  )
    .addOptionalParam("dueDuration", "Define the fees on reward that should be taken depending on time internal of waiting.", '0', types.string)
    .addOptionalParam("staking", "Define a name of staking contract in hre.names.", '', types.string)
    .setAction(async ({ staking, dueDuration }, hre) => {
      await hre.names.gather();
      staking = staking !== '' ? staking : hre.names.internal.diamonds.locusStaking.proxy;
      const stakingInstance = await hre.ethers.getContractAt(
        hre.names.internal.diamonds.locusStaking.interface,
        (await hre.deployments.get(staking)).address
      );
      const result = await stakingInstance.getReward(dueDuration);
      console.log(`getReward called:\n${JSON.stringify(result)}`);
    });
