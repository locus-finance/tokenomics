const keccak256 = require('keccak256');
module.exports = (task) =>
  task(
    "grant",
    "Grants role to a certain entity.",
  )
    .addOptionalParam("diamond", "Camel-cased name of the diamond in 'hre.names'.", 'locusStaking', types.string)
    .addOptionalParam("address", "Who or what (address) is going to receive the role.", '0x27f52fd2E60B1153CBD00D465F97C05245D22B82', types.string)
    .addOptionalParam("role", "Name of the role.", 'DELAYED_SENDINGS_QUEUE_PROCESSOR_ROLE', types.string)
    .setAction(async ({diamond, address, role}, hre) => {
      const signers = await hre.ethers.getSigners();
      const deployer = signers[0].address;
      const roleHash = keccak256(role)
      await hre.names.gather();
      await hre.deployments.execute(
        hre.names.internal.diamonds[diamond].proxy,
        { from: deployer, log: true },
        'grantRole',
        address,
        roleHash
      );
      console.log(`Diamond (${diamond}): the role ${role}:<${roleHash}> has been granted to ${address}.`);
    });
