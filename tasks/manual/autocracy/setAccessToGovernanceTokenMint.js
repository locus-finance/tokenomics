const { types } = require("hardhat/config");

module.exports = (task) =>
  task(
    "minter",
    "Grants or revokes mint or burn access of Governance Token.",
  )
    .addOptionalParam("diamond", "Camel-cased name of the diamond in 'hre.names' or address.", 'locusStaking', types.string)
    .addOptionalParam("address", "Who or what (address) is going to receive an access (to mint or burn) or from whom it would be revoked.", '0xE0042827FEA7d3da413D60A602C7DF369b89A6eA', types.string)
    .addOptionalParam("confirmations", "An amount of confirmations to wait.", 10, types.int)
    .addOptionalParam("status", "Status access.", false, types.boolean)
    .setAction(async ({ diamond, address, confirmations, status}, hre) => {
      await hre.names.gather();
      let diamondInstance;
      if (diamond.startsWith("0x")) {
        diamondInstance = await hre.ethers.getContractAt(
          hre.names.internal.diamonds.locusToken.interface,
          diamond
        );
      } else {
        diamondInstance = await hre.ethers.getContractAt(
          hre.names.internal.diamonds[diamond].interface,
          (await hre.deployments.get(hre.names.internal.diamonds[diamond].proxy)).address
        );
      }
      const setStatusOfMintingBurningSelectorsForTx = await diamondInstance.setStatusOfMintingBurningSelectorsFor(address, status);
      await setStatusOfMintingBurningSelectorsForTx.wait(confirmations);
      console.log(`An access for Governance Token mint or burn operation is set (${status}) for ${address}:`);
      console.log(`Hash: ${setStatusOfMintingBurningSelectorsForTx.hash}`);
      console.log();
    });
