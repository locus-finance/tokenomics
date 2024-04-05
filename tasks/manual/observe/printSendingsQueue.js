module.exports = (task) =>
  task(
    "printQueue",
    "Print a queue of sendings in LOCUS Staking Contract.",
  )
    .addOptionalParam("contract", "Define a name of staking contract in hre.names.", '0x6390743ccb7928581F61427652330a1aEfD885c2', types.string)
    .setAction(async ({ contract }, hre) => {
      // Has to be executed so all HRE extendings would perform their lazy initialization.
      await hre.names.gather();
      let contractAddress;
      if (contract.startsWith("0x")) {
        contractAddress = contract;
      } else {
        contractAddress = (await hre.deployments.get(contract));
      }
      const stakingInstance = await hre.ethers.getContractAt(
        hre.names.internal.diamonds.locusStaking.interface,
        contractAddress
      );
      const queue = await stakingInstance.getSendingsDeque();
      console.log('The queue is acquired:');
      console.log(queue.map(e => {
        return {
          receiver: e.receiver,
          amount: hre.ethers.utils.formatEther(e.amount),
          dueToTimestamp: e.dueToTimestamp.toString(),
          dueToDuration: e.dueToDuration,
          sendingToken: e.sendingToken
        }
      }));
      console.log('The queue has ended and decoded correctly.');
      console.log(`Length of the queue: ${queue.length}`);
      console.log(`Total volume of the queue: ${hre.ethers.utils.formatEther(queue.reduce((a, b) => a[1] + b[1]))}`);
    });
