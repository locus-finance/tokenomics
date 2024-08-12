const { types } = require("hardhat/config");

module.exports = (task) =>
  task(
    "full",
    "Transfers full ownership over the tokenomics all aspects.",
  )
    .addOptionalParam("newOwner", "New autocrat address.", '0x3C2792d5Ea8f9C03e8E73738E9Ed157aeB4FeCBe', types.string)
    .addOptionalParam("newBackend", "New backend address.", '0x717f5cE5A5aF7AC5f48daCDf9AaC45b23a299db7', types.string)
    .addOptionalParam("oldBackend", "Old backend address.", '0x609108771e65C1E736F9630497025b48E15929ab', types.string)
    .addOptionalParam("confirmations", "An amount of confirmations to wait.", 10, types.int)
    .setAction(async ({ newOwner, newBackend, oldBackend, confirmations }, hre) => {
      await hre.names.gather();

      const stakingAddresses = [
        "0xFCE625E69Bd4952417Fe628bC63D9AA0e4012684", // locus autoreflective staking
        "0x24d6D6af23Cd865B4Dee7f169CA60Bf07B4DD9AE", // pendleETH vault tokens staking
        "0x6C447230F098CDdB62f6AEaeEc25C27E8b90B25e", // xARB vault tokens staking
        "0x91A894C32B14F26f708389E5F8e21964b7d3C025", // xDEFI vault tokens staking
        "0xCC50DC869546524E675121fC331249727A549027", // xETH vault tokens staking
        "0x6390743ccb7928581F61427652330a1aEfD885c2", // xUSD vault tokens staking
      ];
      const midasClaimAddress = "0x445816ac3E78D1B0547b4642b373A88aD875cc8a";
      const locusTokenAddress = "0xe1d3495717f9534Db67A6A8d4940Dd17435b6A9E";

      for (const stakingAddress of stakingAddresses) {
        console.log('Working with', stakingAddress);
        await hre.run("transfer", {
          diamond: stakingAddress,
          address: newOwner,
          confirmations
        });
        await hre.run("ownership", {
          diamond: stakingAddress,
          address: newOwner,
          confirmations
        });
      }

      await hre.run("midas", {
        contract: midasClaimAddress,
        address: newOwner,
        confirmations
      });

      console.log('Managing mint/burn ops access');
      await hre.run("minter", {
        diamond: locusTokenAddress,
        address: oldBackend,
        status: false,
        confirmations
      });
      await hre.run("minter", {
        diamond: locusTokenAddress,
        address: newBackend,
        status: true,
        confirmations
      });
      console.log('Managed mint/burn ops access');

      await hre.run("transfer", {
        diamond: locusTokenAddress,
        address: newOwner,
        confirmations
      });
      await hre.run("ownership", {
        diamond: locusTokenAddress,
        address: newOwner,
        confirmations
      });

      console.log('Tokenomics is transferred.');
    });
