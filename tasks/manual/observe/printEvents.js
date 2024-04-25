const { types } = require("hardhat/config");
const fsExtra = require("fs-extra");

module.exports = (task) =>
  task(
    "events",
    "Prints last events.",
  )
    .addOptionalParam("end", "Define an ending point block to search deposits.", 204663841, types.int)
    .addOptionalParam("start", "Define an starting point block to search deposits.", 203684120, types.int)
    .addOptionalParam("contract", "Define a name of staking contract in hre.names.", '0xFCE625E69Bd4952417Fe628bC63D9AA0e4012684', types.string)
    .addOptionalParam("event", "Define a name of staking contract in hre.names.", 'RewardAdded', types.string)
    .addOptionalParam("abi", "Specify the ABI of the event.", "event RewardAdded(uint256 indexed amount)", types.string)
    .setAction(async ({ event, contract, start, end, abi }, hre) => {
      await hre.names.gather();
      let contractAddress;
      if (contract.startsWith("0x")) {
        contractAddress = contract;
      } else {
        contractAddress = (await hre.deployments.get(contract));
      }
      const eventsAbi = [abi];
      const contractInstanceForQueryingEvents = new hre.ethers.Contract(contractAddress, eventsAbi, hre.ethers.provider);
      const filter = contractInstanceForQueryingEvents.filters[event]();
      const rawEvents = await contractInstanceForQueryingEvents.queryFilter(filter, start, end);
      const decodedEvents = rawEvents.map(e => {
        const log = contractInstanceForQueryingEvents.interface.parseLog({
          data: e.data,
          topics: e.topics
        });
        return {
          blockNumber: e.blockNumber,
          log,
          args: log.args
        }
      });
      console.log('Found events and their logs:');
      console.log(decodedEvents);
    });
