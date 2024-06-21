const { types } = require("hardhat/config");
const keccak256 = require('keccak256');
module.exports = (task) =>
  task(
    "roles",
    "Print roles of certain entity.",
  )
    .addOptionalParam("diamond", "Camel-cased name of the diamond in 'hre.names'.", 'autoreflectiveStaking', types.string)
    .addOptionalParam("address", "Who or what (address) is going to scanned for role possession.", '0x609108771e65C1E736F9630497025b48E15929ab', types.string)
    .setAction(async ({ diamond, address }, hre) => {
      await hre.names.gather();
      const allRoles = hre.config.customTokenomicsConfig.roles;
      const rolesGrantedToAddress = [];
      const diamondInstance = await hre.ethers.getContractAt(
        hre.names.internal.diamonds[diamond].interface,
        (await hre.deployments.get(hre.names.internal.diamonds[diamond].proxy)).address
      );
      for (const role of allRoles) {
        const roleHash = keccak256(role);
        const hasRole = await diamondInstance.hasRole(address, roleHash);
        if (hasRole) {
          rolesGrantedToAddress.push(role);
        }
      }
      console.log(`Diamond (${diamond}): ${address} has roles:`);
      console.log(rolesGrantedToAddress);
    });
