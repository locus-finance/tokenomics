const { types } = require("hardhat/config");
module.exports = (task) =>
  task(
    "supply",
    "Call totalSupply() on EIP20 contract.",
  )
    .addOptionalParam("address", "Define an address to be checked.", '', types.string)
    .addOptionalParam("contract", "Define a name of staking contract in hre.names.", '', types.string)
    .setAction(async ({ contract }, hre) => {
      await hre.names.gather();
      contract = contract !== '' ? contract : hre.names.internal.diamonds.autoreflectiveStaking.proxy;
      const contractInstance = await hre.ethers.getContractAt(
        hre.names.internal.iERC20,
        (await hre.deployments.get(contract)).address
      );
      const result = await contractInstance.totalSupply();
      console.log(`Total Supply of EIP20 (${contractInstance.address}): ${hre.ethers.utils.formatEther(result)}`);
    });
