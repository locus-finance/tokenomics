const { types } = require("hardhat/config");
module.exports = (task) =>
  task(
    "stake",
    "Call stake(...) on staking contract.",
  )
    .addOptionalParam("amount", "Define an amount to be staked.", '', types.string)
    .addOptionalParam("staking", "Define a name of staking contract in hre.names.", '', types.string)
    .setAction(async ({ amount, staking }, hre) => {
      await hre.names.gather();
      staking = staking !== '' ? staking : hre.names.internal.diamonds.locusStaking.proxy;
      const stakingInstance = await hre.ethers.getContractAt(
        hre.names.internal.diamonds.locusStaking.interface,
        (await hre.deployments.get(staking)).address
      );
      const result = await stakingInstance.stake(amount);
      console.log(`Stake called:\n${JSON.stringify(result)}`);
    });
