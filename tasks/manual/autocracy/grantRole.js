const { types } = require("hardhat/config");
const keccak256 = require('keccak256');
module.exports = (task) =>
  task(
    "grant",
    "Grants role to a certain entity.",
  )
    .addOptionalParam("diamond", "Camel-cased name of the diamond in 'hre.names'.", 'autoreflectiveStaking', types.string)
    .addOptionalParam("address", "Who or what (address) is going to receive the role.", '0xEcc5e0c19806Cf47531F307140e8b042D5Afb952', types.string)
    .addOptionalParam("role", "Name of the role.", 'BALANCE_SOURCE_ROLE', types.string)
    .setAction(async ({diamond, address, role}, hre) => {
      await hre.names.gather();
      const signers = await hre.ethers.getSigners();
      const deployer = signers[0].address;
      const roleHash = keccak256(role);
      await hre.deployments.execute(
        hre.names.internal.diamonds[diamond].proxy,
        { from: deployer, log: true },
        'grantRole',
        address,
        roleHash
      );
      console.log(`Diamond (${diamond}): the role ${role} has been granted to ${address}.`);
    });
