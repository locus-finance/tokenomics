const { types } = require("hardhat/config");
module.exports = (task) =>
  task(
    "locus",
    "Call balanceOf(...) on LOCUS contract.",
  )
    .addOptionalParam("address", "Define an address to be checked.", '', types.string)
    .addOptionalParam("locus", "Define a name of locus contract in hre.names.", '', types.string)
    .setAction(async ({ address, locus }, hre) => {
      await hre.names.gather();
      address = address !== '' ? address : (await hre.ethers.getSingers())[0].address;
      locus = locus !== '' ? locus : hre.names.internal.diamonds.locusToken.proxy;
      const locusInstance = await hre.ethers.getContractAt(
        hre.names.internal.iERC20,
        (await hre.deployments.get(locus)).address
      );
      const result = await locusInstance.balanceOf(address);
      console.log(`LOCUS balance of address (${address}): ${hre.ethers.utils.formatEther(result)}`);
    });
