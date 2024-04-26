const { types } = require("hardhat/config");
module.exports = (task) =>
  task(
    "burn",
    "Burn LOCUS' being an autocrat from defined address.",
  )
    .addOptionalParam("locus", "Define an address of Locus token.", '', types.string)
    .addOptionalParam("amount", "Define amount to be minted.", '0', types.string)
    .addOptionalParam("address", "Define address to be burned from.", '0x729F2222aaCD99619B8B660b412baE9fCEa3d90F', types.string)
    .addOptionalParam("confirmations", "An amount of confirmations to wait.", 10, types.int)
    .setAction(async ({ amount, address, confirmations, locus }, hre) => {
      await hre.names.gather();
      const locusAddress = locus !== '' ? locus : (await hre.deployments.get(hre.names.internal.diamonds.locusToken.proxy)).address;
      const locusTokenInstance = await hre.ethers.getContractAt(
        hre.names.internal.diamonds.locusToken.interface,
        locusAddress
      );
      const burnTx = await locusTokenInstance.burn(address, hre.ethers.utils.parseEther(amount));
      await burnTx.wait(confirmations);
      console.log(`Tx:\n${JSON.stringify(burnTx)}`);
      console.log(`${locus}: Burned LOCUS' amount ${amount} from address - ${address}`);
    });
