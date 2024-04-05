const { retryTxIfFailed } = require("../../../deploy/helpers");
module.exports = (task) =>
  task(
    "queue",
    "Clear a queue of sendings in LOCUS Staking Contract.",
  )
    .addOptionalParam("diamond", "Camel-cased name of the diamond in 'hre.names'.", 'autoreflectiveStaking', types.string)
    .addOptionalParam("confirmations", "An amount of confirmations to wait.", 10, types.int)
    .setAction(async ({ diamond, confirmations } , hre) => {
      await hre.names.gather();
      let stakingInstance;
      if (diamond.startsWith("0x")) {
        stakingInstance = await hre.ethers.getContractAt(
          hre.names.internal.diamonds.locusStaking.interface,
          diamond
        );
      } else {
        stakingInstance = await hre.ethers.getContractAt(
          hre.names.internal.diamonds[diamond].interface,
          (await hre.deployments.get(hre.names.internal.diamonds[diamond].proxy)).address
        );
      }

      let processQueueTxMetadata;
      if ((await stakingInstance.getDequeSize()).gt(0)) {
        processQueueTxMetadata = await retryTxIfFailed(
          stakingInstance, "processQueue", [], confirmations
        );
        console.log(`Diamond(${diamond}): the queue has been cleared. Gas used: ${processQueueTxMetadata.gas}:\nTx info: ${JSON.stringify(processQueueTxMetadata.receipt)}`);
      } else {
        console.log('Nothing to clear.');
      }
    });
