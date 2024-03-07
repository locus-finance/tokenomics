const { types } = require("hardhat/config");
module.exports = (task) =>
  task(
    "stake",
    "Stake for the deployer.",
  )
    .addOptionalParam("token", "Define a name of staking token in hre.names.", '', types.string)
    .addOptionalParam("staking", "Define a name of staking contract in hre.names.", '', types.string)
    .addOptionalParam("amount", "Define amount to be staked.", '32500000000000000000000', types.string)
    .setAction(async ({ amount, token, staking }, hre) => {
      await hre.names.gather();
      
      staking = staking !== '' ? staking : hre.names.internal.diamonds.locusStaking.proxy;
      token = token !== '' ? token : hre.names.internal.diamonds.locusToken.proxy;

      const locusStakingInstance = await hre.ethers.getContractAt(
        hre.names.internal.diamonds.locusStaking.interface,
        (await hre.deployments.get(staking)).address
      );
      const locusToken = await hre.ethers.getContractAt(
        hre.names.internal.diamonds.locusToken.interface,
        (await hre.deployments.get(token)).address
      );

      const approveTx = await locusToken.approve(locusStakingInstance.address, amount);
      await approveTx.wait();
      const stakeTx = await locusStakingInstance.stake(amount);
      await stakeTx.wait();

      console.log(`Tx:\n${JSON.stringify(stakeTx)}`);
      console.log(`Staked LOCUS' amount ${hre.ethers.utils.formatUnits(amount)}`);
    });
