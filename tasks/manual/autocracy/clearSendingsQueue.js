module.exports = (task) =>
  task(
    "queue",
    "Clear a queue of sendings in LOCUS Staking Contract.",
  )
    .addOptionalParam("diamond", "Camel-cased name of the diamond in 'hre.names'.", 'autoreflectiveStaking', types.string)
    .setAction(async ({ diamond } , hre) => {
      const signers = await hre.ethers.getSigners();
      const deployer = signers[0];

      await hre.names.gather();

      const stakingInstance = await hre.ethers.getContractAt(
        hre.names.internal.diamonds[diamond].interface,
        (await hre.deployments.get(hre.names.internal.diamonds[diamond].proxy)).address
      );
      let processQueueTx;
      if ((await stakingInstance.getDequeSize()).gt(0)) {
        processQueueTx = await stakingInstance.connect(deployer).processQueue();
        await processQueueTx.wait();
      }
      if (processQueueTx === undefined) {
        console.log('Nothing to clear.');
      } else {
        console.log(`Diamond(${diamond}): the queue has been cleared:\n${JSON.stringify(processQueueTx)}`);
      }
    });
