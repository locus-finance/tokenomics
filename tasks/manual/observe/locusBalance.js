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
      locus = locus !== '' ? locus : (await hre.deployments.get(hre.names.internal.diamonds.locusToken.proxy)).address;
      const locusInstance = await hre.ethers.getContractAt(
        hre.names.internal.iERC20,
        locus
      );
      const result = await locusInstance.balanceOf(address);
      console.log(`LOCUS balance of address (${address}): ${hre.ethers.utils.formatEther(result)}`);
      return result;
    });
