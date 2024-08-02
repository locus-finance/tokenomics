const { types } = require("hardhat/config");

module.exports = (task) =>
  task(
    "ownership",
    "Transfers an access to `diamondCut(...)` function.",
  )
    .addOptionalParam("diamond", "Camel-cased name of the diamond in 'hre.names' or address.", 'locusStaking', types.string)
    .addOptionalParam("address", "Who or what (address) is going to receive diamond ownership (access to `diamondCut(...)` func).", '0xE0042827FEA7d3da413D60A602C7DF369b89A6eA', types.string)
    .addOptionalParam("confirmations", "An amount of confirmations to wait.", 10, types.int)
    .setAction(async ({ diamond, address, confirmations}, hre) => {
      await hre.names.gather();
      let diamondInstance;
      if (diamond.startsWith("0x")) {
        diamondInstance = await hre.ethers.getContractAt(
          "Ownable",
          diamond
        );
      } else {
        diamondInstance = await hre.ethers.getContractAt(
          "Ownable",
          (await hre.deployments.get(hre.names.internal.diamonds[diamond].proxy)).address
        );
      }
      const transferOwnershipTx = await diamondInstance.transferOwnership(address);
      await transferOwnershipTx.wait(confirmations);
      console.log(`Ownership of the diamond (${diamond}) is transferred to - ${address}:`);
      console.log(transferOwnershipTx);
    });
