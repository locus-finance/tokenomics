module.exports = (task) =>
  task(
    "queue",
    "Clear a queue of sendings in LOCUS Staking Contract.",
  )
    .setAction(async (_, hre) => {
      const signers = await hre.ethers.getSigners();
      const deployer = signers[0].address;
      await hre.deployments.execute(
        hre.names.internal.diamonds.locusStaking.proxy,
        { from: deployer, log: true },
        'processQueue'
      );
      console.log(`The queue has been cleared.`);
    });
