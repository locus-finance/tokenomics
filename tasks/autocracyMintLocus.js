const { types } = require("hardhat/config");
module.exports = (task) =>
  task(
    "mint",
    "Mint LOCUS being an autocrat to the fundraising address.",
  )
    .addOptionalParam("amount", "Define amount to be minted.", '529959380000000000000', types.string)
    .addOptionalParam("address", "Define address to be minted to.", '0x445816ac3E78D1B0547b4642b373A88aD875cc8a', types.string)
    .setAction(async ({ amount, address }, hre) => {
      const signers = await hre.ethers.getSigners();
      const deployer = signers[0].address;
      await hre.deployments.execute(
        hre.names.internal.diamonds.locusToken.proxy,
        { from: deployer, log: true },
        'mint',
        address,
        amount
      );
      console.log(`Minted LOCUS' amount ${hre.ethers.utils.formatUnits(amount)} to address - ${address}`);
    });
