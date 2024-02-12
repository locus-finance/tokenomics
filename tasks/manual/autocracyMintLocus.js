const { types } = require("hardhat/config");
module.exports = (task) =>
  task(
    "mint",
    "Mint LOCUS being an autocrat to the fundraising address.",
  )
    .addOptionalParam("locus", "Define a name of Locus token in hre.names.", '', types.string)
    .addOptionalParam("amount", "Define amount to be minted.", '3300000000000000000000000', types.string)
    .addOptionalParam("address", "Define address to be minted to.", '0x445816ac3E78D1B0547b4642b373A88aD875cc8a', types.string)
    .setAction(async ({ amount, address, locus }, hre) => {
      const signers = await hre.ethers.getSigners();
      const deployer = signers[0].address;
      await hre.names.gather();
      await hre.deployments.execute(
        locus === '' 
          ? hre.names.internal.diamonds.locusToken.proxy
          : locus,
        { from: deployer, log: true },
        'mint',
        address,
        amount
      );
      console.log(`${locus}: Minted LOCUS' amount ${hre.ethers.utils.formatUnits(amount)} to address - ${address}`);
    });
