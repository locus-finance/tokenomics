const { types } = require("hardhat/config");

module.exports = (task) =>
  task(
    "midas",
    "Transfers ownership over MidasClaim contract.",
  )
    .addOptionalParam("contract", "Camel-cased name in 'hre.names' or address of the MidasClaim contract.", 'MidasClaim', types.string)
    .addOptionalParam("address", "Who or what (address) is going to receive MidasClaim ownership.", '0xE0042827FEA7d3da413D60A602C7DF369b89A6eA', types.string)
    .addOptionalParam("confirmations", "An amount of confirmations to wait.", 10, types.int)
    .setAction(async ({ contract, address, confirmations }, hre) => {
      await hre.names.gather();
      let contractInstance;
      if (contract.startsWith("0x")) {
        contractInstance = await hre.ethers.getContractAt(
          hre.names.internal.midasClaim,
          contract
        );
      } else {
        contractInstance = await hre.ethers.getContractAt(
          hre.names.internal.midasClaim,
          (await hre.deployments.get(contract)).address
        );
      }
      const transferOwnershipTx = await contractInstance.transferOwnership(address);
      await transferOwnershipTx.wait(confirmations);
      console.log(`Ownership of the MidasClaim contract (${contract}) is transferred to - ${address}:`);
      console.log(transferOwnershipTx);
    });
