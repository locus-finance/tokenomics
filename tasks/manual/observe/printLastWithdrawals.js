const { types } = require("hardhat/config");
const fsExtra = require("fs-extra");

module.exports = (task) =>
  task(
    "printLastWithdrawals",
    "Prints last withdrawals events.",
  )
    .addOptionalParam("csv", "A CSV data gathered.", './resources/csv/lastWithdrawalsXUsd.csv', types.string)
    .addOptionalParam("decimals", "Define an ending point block to search withdrawals.", 18, types.int)
    .addOptionalParam("end", "Define an ending point block to search withdrawals.", 197843913, types.int)
    .addOptionalParam("start", "Define an starting point block to search withdrawals.", 195439487, types.int)
    .addOptionalParam("contract", "Define a name of staking contract in hre.names.", '0x6390743ccb7928581F61427652330a1aEfD885c2', types.string)
    .setAction(async ({ contract, start, end, csv, decimals }, hre) => {
      await hre.names.gather();
      let contractAddress;
      if (contract.startsWith("0x")) {
        contractAddress = contract;
      } else {
        contractAddress = (await hre.deployments.get(contract));
      }
      const eventsAbi = [
        "event SentOut(address indexed token,address indexed user,uint256 indexed amount,uint256 feesTaken)"
      ];
      
      const contractInstanceForQueryingEvents = new hre.ethers.Contract(contractAddress, eventsAbi, hre.ethers.provider);
      const filter = contractInstanceForQueryingEvents.filters.SentOut();
      const rawEvents = await contractInstanceForQueryingEvents.queryFilter(filter, start, end);
      const decodedEvents = rawEvents.map(e => {
        return {
          blockNumber: e.blockNumber,
          txHash: e.transactionHash,
          log: contractInstanceForQueryingEvents.interface.parseLog({
            data: e.data,
            topics: e.topics
          })
        }
      });
      let csvString = "\"user\",\"amount\",\"feesTaken\",\"blockNumber\",\"txHash\"\n";
        for (const eventData of decodedEvents) {
          const amount = eventData.log.args.amount;
          const user = eventData.log.args.user;
          const feesTaken = eventData.log.args.feesTaken;
          csvString += `\"${user}\",${hre.ethers.utils.formatUnits(amount, decimals)},${hre.ethers.utils.formatUnits(feesTaken, decimals)},${eventData.blockNumber},\"${eventData.txHash}\"\n`;
        }
        await fsExtra.outputFile(csv, csvString);
        console.log(`CSV table stored in: ${csv}`);
    });
