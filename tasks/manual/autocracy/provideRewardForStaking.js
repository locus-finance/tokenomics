const { types } = require("hardhat/config");
const { retryTxIfFailed } = require("../../../deploy/helpers");

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
      if (amount === "0") throw Error("Nothing to provide. Zero is past as amount parameter.");
      const signers = await hre.ethers.getSigners();
      const deployer = signers[0].address;
      await hre.names.gather();
      
      const locusStakingAddress = staking === '' ? (await hre.deployments.get(hre.names.internal.diamonds.autoreflectiveStaking.proxy)).address : staking;
      const locusTokenAddress = locus === '' ? (await hre.deployments.get(hre.names.internal.diamonds.locusToken.proxy)).address : locus;

      console.log(`Using hre.names - Staking Diamond: ${locusStakingAddress}, Locus instance name: ${locusTokenAddress}`);

      const autoreflectiveStaking = await hre.ethers.getContractAt(
        hre.names.internal.diamonds.autoreflectiveStaking.interface,
        locusStakingAddress
      );
      const locusToken = await hre.ethers.getContractAt(
        hre.names.internal.diamonds.locusToken.interface,
        locusTokenAddress
      );

      const amountWei = hre.ethers.utils.parseEther(amount);
      
      const deployerBalance = await locusToken.balanceOf(deployer); 
      if (deployerBalance.lt(amountWei)) {
        console.log(`The deployer has not enough funds to provide (${hre.ethers.utils.formatEther(deployerBalance)} LOCUS') - minting ${amount} LOCUS'...`);
        await hre.run('mint', {
          locus,
          amount: amount,
          address: deployer,
          confirmations
        });
      } else {
        console.log(`The deployer has enough funds to provide (${hre.ethers.utils.formatEther(deployerBalance)} LOCUS') - continue...`);
      }

      const approveTxMetadata = await retryTxIfFailed(
        hre, locusToken, "approve", [autoreflectiveStaking.address, amountWei], confirmations
      );
      console.log(`Diamond(${staking}): approved LOCUS' (gas: ${approveTxMetadata.gas}). Tx info:\n${JSON.stringify(approveTxMetadata.receipt)}`);
      
      const notifyRewardAmountTxMetadata = await retryTxIfFailed(
        hre, autoreflectiveStaking, "notifyRewardAmount", [amountWei], confirmations
      );
      console.log(`Success: notifyRewardAmount(${amount}) called (gas used: ${notifyRewardAmountTxMetadata.gas}):\n${JSON.stringify(notifyRewardAmountTxMetadata.receipt)}`);
    });
