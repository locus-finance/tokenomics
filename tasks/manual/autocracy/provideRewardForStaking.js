const { types } = require("hardhat/config");
const keccak256 = require('keccak256');
module.exports = (task) =>
  task(
    "provide",
    "Provide LOCUS' for the staking contract.",
  )
    // wei amount for autoreflective token is 1083333333333333333334 and has to be called once a day
    // wei amount for autoreflective token is 1778563941240000000000 and it has to be until 15 of april 2024
    // wei amount for autoreflective token is 3250000000000000000000
    .addOptionalParam("amount", "Define amount to be provided.", '0', types.string)
    .addOptionalParam("staking", "Define a custom name of Diamond Staking from hre.names.", '', types.string)
    .addOptionalParam("locus", "Define a name of Diamond Locus Token from hre.names.", '', types.string)
    .addOptionalParam("confirmations", "An amount of confirmations to wait.", 10, types.int)
    .setAction(async ({ amount, staking, locus, confirmations }, hre) => {
      if (amount === "0") throw RuntimeError("Nothing to provide. Zero is past as amount parameter.");
      const signers = await hre.ethers.getSigners();
      const deployer = signers[0].address;
      await hre.names.gather();
      await hre.run('mint', {
        locus,
        amount: amount,
        address: deployer
      });
      
      const locusStakingName = staking === '' ? hre.names.internal.diamonds.autoreflectiveStaking.proxy : staking;
      const locusTokenName = locus === '' ? hre.names.internal.diamonds.locusToken.proxy : locus;

      console.log(`Using hre.names - Staking Diamond: ${locusStakingName}, Locus instance name: ${locusTokenName}`);

      const autoreflectiveStaking = await hre.ethers.getContractAt(
        hre.names.internal.diamonds.autoreflectiveStaking.interface,
        (await hre.deployments.get(locusStakingName)).address
      );
      const locusToken = await hre.ethers.getContractAt(
        hre.names.internal.diamonds.locusToken.interface,
        (await hre.deployments.get(locusTokenName)).address
      );

      const amountWei = hre.ethers.utils.parseEther(amount);
      const approveTx = await locusToken.approve(autoreflectiveStaking.address, amountWei);
      await approveTx.wait(confirmations);
      const notifyRewardAmountTx = await autoreflectiveStaking.notifyRewardAmount(amountWei);
      await notifyRewardAmountTx.wait(confirmations);
      console.log(`Success: notifyRewardAmount(${amount}) called:\n${JSON.stringify(notifyRewardAmountTx)}`);
    });
