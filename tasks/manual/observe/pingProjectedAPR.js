const { types } = require("hardhat/config");
module.exports = (task) =>
  task(
    "apr",
    "Calculate projected APR for the staking contract.",
  )
    .addOptionalParam("duration", "Define duration of the staking epoch in seconds for the calculation", `${3600 * 24 * 7 * 4}`, types.string)
    .addOptionalParam("total", "Define total reward amount for the calculation", '32500000000000000000000', types.string)
    .addOptionalParam("staking", "Define a name of staking contract in hre.names.", '', types.string)
    .setAction(async ({ total, duration, staking }, hre) => {
      await hre.names.gather();
      staking = staking !== '' ? staking : hre.names.internal.diamonds.locusStaking.proxy;
      const stakingInstance = await hre.ethers.getContractAt(
        hre.names.internal.diamonds.locusStaking.interface,
        (await hre.deployments.get(staking)).address
      );
      const totalReward = hre.ethers.BigNumber.from(total);
      const rewardsDuration = hre.ethers.BigNumber.from(duration);
      const result = await stakingInstance.getProjectedAPR(totalReward.div(rewardsDuration), rewardsDuration);
      console.log(`Projected APR:\n${result}`);
    });
