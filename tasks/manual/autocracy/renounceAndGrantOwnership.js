const keccak256 = require('keccak256');
const { types } = require("hardhat/config");

module.exports = (task) =>
  task(
    "transfer",
    "Grants to new address all of the roles and renounces them from the original owner.",
  )
    .addOptionalParam("diamond", "Camel-cased name of the diamond in 'hre.names'.", 'locusStaking', types.string)
    .addOptionalParam("address", "Who or what (address) is going to receive the roles.", '0xE0042827FEA7d3da413D60A602C7DF369b89A6eA', types.string)
    .setAction(async ({ diamond, address }, hre) => {
      const signers = await hre.ethers.getSigners();
      const deployer = signers[0].address;
      await hre.names.gather();
      // gather all roles
      const allRoles = hre.config.customTokenomicsConfig.roles;
      const rolesHashes = allRoles.map(keccak256);
      const firstArgument = allRoles.map(_ => address);
      const firstArgumentForRevokeRole = allRoles.map(_ => deployer);
      await hre.deployments.execute(
        hre.names.internal.diamonds[diamond].proxy,
        { from: deployer, log: true },
        'grantRoles',
        firstArgument,
        rolesHashes
      );
      await hre.deployments.execute(
        hre.names.internal.diamonds[diamond].proxy,
        { from: deployer, log: true },
        'revokeRoles',
        firstArgumentForRevokeRole,
        rolesHashes
      );
      console.log(`The roles:\n${allRoles}\nhas been transferred from deployer:<${deployer}> to: ${address}`);
    });
