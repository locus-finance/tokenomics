const { types } = require("hardhat/config");
module.exports = (task) =>
  task(
    "mint",
    "Mint LOCUS being an autocrat to the fundraising address.",
  )
    .addOptionalParam("locus", "Define a name of Locus token in hre.names.", '', types.string)
    .addOptionalParam("amount", "Define amount to be minted.", '0', types.string)
    .addOptionalParam("address", "Define address to be minted to.", '0x729F2222aaCD99619B8B660b412baE9fCEa3d90F', types.string)
    .addOptionalParam("confirmations", "An amount of confirmations to wait.", 10, types.int)
    .setAction(async ({ amount, address, locus, confirmations }, hre) => {
      await hre.names.gather();
      const locusTokenInstance = await hre.ethers.getContractAt(
        hre.names.internal.diamonds.locusToken.interface,
        (await hre.deployments.get(hre.names.internal.diamonds.locusToken.proxy)).address
      );
      const mintTx = await locusTokenInstance.mint(address, hre.ethers.utils.parseEther(amount)); 
      await mintTx.wait(confirmations);
      console.log(`${locus}: Minted LOCUS' amount ${amount} to address - ${address}`);
      console.log(`Tx info:\n${JSON.stringify(mintTx)}`);
    });
