module.exports = (task) =>
  task(
    "printQueue",
    "Print a queue of sendings in LOCUS Staking Contract.",
  )
    .setAction(async (_, hre) => {
      // Has to be executed so all HRE extendings would perform their lazy initialization.
      const signers = await hre.ethers.getSigners();
      const deployer = signers[0];
      const locusStakingInstance = await hre.ethers.getContractAt(
        hre.names.internal.diamonds.locusStaking.interface,
        (await hre.deployments.get(hre.names.internal.diamonds.locusStaking.proxy)).address
      );
      const queue = await locusStakingInstance.connect(deployer).getSendingsDeque();
      console.log('The queue is acquired:');
      console.log(queue);
      console.log('The queue has ended and decoded correctly.');
    });
