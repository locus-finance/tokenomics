const { types } = require("hardhat/config");
module.exports = (task) =>
  task(
    "burn",
    "Burn LOCUS' being an autocrat from defined address.",
  )
    .addOptionalParam("amount", "Define amount to be minted.", '32500000000000000000000', types.string)
    .addOptionalParam("address", "Define address to be burned from.", '0x729F2222aaCD99619B8B660b412baE9fCEa3d90F', types.string)
    .setAction(async ({ amount, address }, hre) => {
      await hre.names.gather();
      const locusTokenInstance = await hre.ethers.getContractAt(
        hre.names.internal.diamonds.locusToken.interface,
        (await hre.deployments.get(hre.names.internal.diamonds.locusToken.proxy)).address
      );
      const burnTx = await locusTokenInstance.burn(address, amount);
      await burnTx.wait();
      console.log(`Tx:\n${JSON.stringify(burnTx)}`);
      console.log(`Burned LOCUS' amount ${hre.ethers.utils.formatUnits(amount)} from address - ${address}`);
    });
