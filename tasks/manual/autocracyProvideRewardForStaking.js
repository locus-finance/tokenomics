const { types } = require("hardhat/config");
const keccak256 = require('keccak256');
module.exports = (task) =>
  task(
    "provide",
    "Provide LOCUS' for the staking contract.",
  )
    // amount for autoreflective token is 1083333333333333333334 and has to be called once a day
    .addOptionalParam("amount", "Define amount to be provided.", '32500000000000000000000', types.string)
    .addOptionalParam("staking", "Define a custom name of Diamond Staking from hre.names.", '', types.string)
    .addOptionalParam("locus", "Define a name of Diamond Locus Token from hre.names.", '', types.string)
    .setAction(async ({ amount, staking, locus }, hre) => {
      const signers = await hre.ethers.getSigners();
      const deployer = signers[0].address;
      await hre.names.gather();
      await hre.run('mint', {
        locus,
        amount: amount,
        address: deployer
      });
      
      const locusStakingName = staking === '' ? hre.names.internal.diamonds.locusStaking.proxy : staking;
      const locusTokenName = locus === '' ? hre.names.internal.diamonds.locusToken.proxy : locus;

      console.log(`Using hre.names - Staking Diamond: ${locusStakingName}, Locus instance name: ${locusTokenName}`);

      const locusStaking = await hre.ethers.getContractAt(
        hre.names.internal.diamonds.locusStaking.interface,
        (await hre.deployments.get(locusStakingName)).address
      );
      const locusToken = await hre.ethers.getContractAt(
        hre.names.internal.diamonds.locusToken.interface,
        (await hre.deployments.get(locusTokenName)).address
      );

      const approveTx = await locusToken.approve(locusStaking.address, amount);
      await approveTx.wait();
      const notifyRewardAmountTx = await locusStaking.notifyRewardAmount(amount);
      await notifyRewardAmountTx.wait();
      console.log(`Success: notifyRewardAmount(${amount}) called:\n${JSON.stringify(notifyRewardAmountTx)}`);
    });
