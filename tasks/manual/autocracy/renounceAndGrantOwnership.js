const keccak256 = require('keccak256');
const { types } = require("hardhat/config");

module.exports = (task) =>
  task(
    "transfer",
    "Grants to new address all of the roles and renounces them from the original owner.",
  )
    .addOptionalParam("diamond", "Camel-cased name of the diamond in 'hre.names'. or address", 'locusStaking', types.string)
    .addOptionalParam("address", "Who or what (address) is going to receive the roles.", '0xE0042827FEA7d3da413D60A602C7DF369b89A6eA', types.string)
    .addOptionalParam("confirmations", "An amount of confirmations to wait.", 10, types.int)
    .setAction(async ({ diamond, address, confirmations}, hre) => {
      await hre.names.gather();
      const signers = await hre.ethers.getSigners();
      const deployer = signers[0].address;
      // gather all roles
      const allRoles = hre.config.customTokenomicsConfig.roles;
      const rolesHashes = allRoles.map(keccak256);
      const firstArgument = allRoles.map(_ => address);
      const firstArgumentForRevokeRole = allRoles.map(_ => deployer);

      let diamondInstance;
      if (diamond.startsWith("0x")) {
        diamondInstance = await hre.ethers.getContractAt(
          hre.names.internal.diamonds.locusStaking.interface,
          diamond
        );
      } else {
        diamondInstance = await hre.ethers.getContractAt(
          hre.names.internal.diamonds[diamond].interface,
          (await hre.deployments.get(hre.names.internal.diamonds[diamond].proxy)).address
        );
      }

      const grantRolesTx = await diamondInstance.grantRoles(firstArgument, rolesHashes);
      await grantRolesTx.wait(confirmations);
      console.log(`Roles to new owner granted:`);
      console.log(grantRolesTx.hash);
      console.log('---');
      const revokeRolesTx = await diamondInstance.revokeRoles(firstArgumentForRevokeRole, rolesHashes);
      await revokeRolesTx.wait(confirmations);
      console.log(`Roles from old owner revoked:`);
      console.log(revokeRolesTx.hash);
      console.log('***');
      console.log(`The roles:\n${allRoles}\nhas been transferred from deployer:<${deployer}> to: ${address}`);
      console.log();
    });
