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
        "DiamondLocusStaking",// hre.names.internal.diamonds.locusStaking.interface,
        (await hre.deployments.get("LocusStaking_DiamondProxy")).address
      );
      const queue = await locusStakingInstance.connect(deployer).getSendingsDeque();
      console.log('The queue is acquired:');
      console.log(queue);
      console.log('The queue has ended and decoded correctly.');
      console.log(`Length of the queue: ${queue.length}`);
      console.log(`Total volume of the queue: ${hre.ethers.utils.formatEther(queue.reduce((a, b) => a[1] + b[1]))}`);
    });
