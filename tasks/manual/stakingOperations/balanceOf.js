const { types } = require("hardhat/config");
module.exports = (task) =>
  task(
    "balance",
    "Call balanceOf(...) on staking contract.",
  )
    .addOptionalParam("address", "Define an address to be checked.", '', types.string)
    .addOptionalParam("staking", "Define a name of staking contract in hre.names.", '', types.string)
    .setAction(async ({ address, staking }, hre) => {
      await hre.names.gather();
      address = address !== '' ? address : (await hre.ethers.getSingers())[0].address;
      staking = staking !== '' ? staking : hre.names.internal.diamonds.locusStaking.proxy;
      const stakingInstance = await hre.ethers.getContractAt(
        hre.names.internal.iERC20,
        (await hre.deployments.get(staking)).address
      );
      const result = await stakingInstance.balanceOf(address);
      console.log(`Balance of address (${address}): ${hre.ethers.utils.formatEther(result)}`);
    });
