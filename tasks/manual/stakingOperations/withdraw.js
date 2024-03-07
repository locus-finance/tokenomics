const { types } = require("hardhat/config");
module.exports = (task) =>
  task(
    "withdraw",
    "Call withdraw(...) on staking contract.",
  )
    .addOptionalParam("dueDuration", "Define the fees that should be taken depending on time internal of waiting.", '1', types.string)
    .addOptionalParam("amount", "Define an amount to be staked.", '1000000000000000000', types.string)
    .addOptionalParam("staking", "Define a name of staking contract in hre.names.", '', types.string)
    .setAction(async ({ amount, staking, dueDuration }, hre) => {
      await hre.names.gather();
      staking = staking !== '' ? staking : hre.names.internal.diamonds.locusStaking.proxy;
      const stakingInstance = await hre.ethers.getContractAt(
        hre.names.internal.diamonds.locusStaking.interface,
        (await hre.deployments.get(staking)).address
      );
      const result = await stakingInstance.withdraw(amount, dueDuration);
      console.log(`Withdraw called:\n${JSON.stringify(result)}`);
    });
