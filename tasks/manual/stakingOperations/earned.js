const { types } = require("hardhat/config");
module.exports = (task) =>
  task(
    "earned",
    "Call earned(...) on staking contract.",
  )
    .addOptionalParam("address", "Define an address to be checked.", '', types.string)
    .addOptionalParam("staking", "Define a name of staking contract in hre.names.", '', types.string)
    .setAction(async ({ address, staking }, hre) => {
      await hre.names.gather();
      address = address !== '' ? address : (await hre.ethers.getSingers())[0].address;
      if (!staking.startsWith("0x")) {
        staking = (await hre.deployments.get(staking)).address;
      }
      const stakingInstance = await hre.ethers.getContractAt(
        hre.names.internal.diamonds.locusStaking.interface,
        staking
      );
      const result = await stakingInstance.earned(address);
      console.log(`Earned by the address (${address}): ${hre.ethers.utils.formatEther(result)}`);
    });
