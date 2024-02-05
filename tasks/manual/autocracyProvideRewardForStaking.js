const { types } = require("hardhat/config");
const keccak256 = require('keccak256');
module.exports = (task) =>
  task(
    "provide",
    "Provide LOCUS' for the staking contract.",
  )
    .addOptionalParam("amount", "Define amount to be provided.", '32500000000000000000000', types.string)
    .setAction(async ({ amount }, hre) => {
      const signers = await hre.ethers.getSigners();
      const deployer = signers[0].address;
      await hre.names.gather();
      await hre.run('mint', {
        amount: amount,
        address: deployer
      });
      const locusStaking = await hre.ethers.getContractAt(
        hre.names.internal.diamonds.locusStaking.interface,
        (await hre.deployments.get(hre.names.internal.diamonds.locusStaking.proxy)).address
      );
      const locusToken = await hre.ethers.getContractAt(
        hre.names.internal.diamonds.locusToken.interface,
        (await hre.deployments.get(hre.names.internal.diamonds.locusToken.proxy)).address
      );

      const approveTx = await locusToken.approve(locusStaking.address, amount);
      await approveTx.wait();
      const notifyRewardAmountTx = await locusStaking.notifyRewardAmount(amount);
      await notifyRewardAmountTx.wait();
      console.log(`Success: notifyRewardAmount(${amount}) called:\n${JSON.stringify(notifyRewardAmountTx)}`);
    });
