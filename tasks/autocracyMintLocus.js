const { types } = require("hardhat/config");
module.exports = (task) =>
  task(
    "mint",
    "Mint LOCUS being an autocrat to the fundraising address.",
  )
    .addOptionalParam("amount", "Define amount to be minted.", '125000000000000000000000', types.string)
    .setAction(async ({ amount }, hre) => {
      const signers = await hre.ethers.getSigners();
      const deployer = signers[0].address;
      await hre.deployments.execute(
        hre.names.internal.diamonds.locusToken.proxy,
        { from: deployer, log: true },
        'mint',
        (await hre.deployments.get(hre.names.external.presale)).address,
        amount
      );
    });
