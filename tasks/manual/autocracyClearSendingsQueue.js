module.exports = (task) =>
  task(
    "queue",
    "Clear a queue of sendings in LOCUS Staking Contract.",
  )
    .setAction(async (_, hre) => {
      const signers = await hre.ethers.getSigners();
      const deployer = signers[0];
      const locusStakingInstance = await hre.ethers.getContractAt(
        "DiamondLocusStaking",// hre.names.internal.diamonds.locusStaking.interface,
        (await hre.deployments.get("LocusStaking_DiamondProxy")).address
      );
      let processQueueTx;
      if ((await locusStakingInstance.getDequeSize()).gt(0)) {
        processQueueTx = await locusStakingInstance.connect(deployer).processQueue();
        await processQueueTx.wait();
      }
      if (processQueueTx === undefined) {
        console.log('Nothing to clear.');
      } else {
        console.log(`The queue has been cleared:\n${JSON.stringify(processQueueTx)}`);
      }
    });
