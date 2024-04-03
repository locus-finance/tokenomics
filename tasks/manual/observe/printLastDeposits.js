const { types } = require("hardhat/config");
const fsExtra = require("fs-extra");

module.exports = (task) =>
  task(
    "printLastDeposits",
    "Prints last deposits events.",
  )
    .addOptionalParam("csv", "A CSV data gathered.", './resources/csv/lastDepositsXUsd.csv', types.string)
    .addOptionalParam("decimals", "Define an ending point block to search deposits.", 6, types.int)
    .addOptionalParam("end", "Define an ending point block to search deposits.", 197127256, types.int)
    .addOptionalParam("start", "Define an starting point block to search deposits.", 192827069, types.int)
    .addOptionalParam("contract", "Define a name of staking contract in hre.names.", '0x6318938F825F57d439B3a9E25C38F04EF97987D8', types.string)
    .addOptionalParam("event", "Define a name of staking contract in hre.names.", 'Deposit', types.string)
    .addOptionalParam("second", "Define if the second overloaded event is utilized.", true, types.boolean)
    .setAction(async ({ event, contract, start, end, csv, decimals, second }, hre) => {
      await hre.names.gather();
      let contractAddress;
      if (contract.startsWith("0x")) {
        contractAddress = contract;
      } else {
        contractAddress = (await hre.deployments.get(contract));
      }
      const eventsAbi = [
        "event Staked(address indexed user,uint256 indexed amount)",
        second 
          ? "event Deposit(address indexed from, uint256 indexed wantTokenAmount, address indexed recipient, uint256 sharesIssued, uint256 timestamp)"
          : "event Deposit(address indexed recipient,uint256 indexed shares,uint256 indexed value,uint256 timestamp)"
      ];
      
      const contractInstanceForQueryingEvents = new hre.ethers.Contract(contractAddress, eventsAbi, hre.ethers.provider);
      const filter = contractInstanceForQueryingEvents.filters[event](null, null);
      const rawEvents = await contractInstanceForQueryingEvents.queryFilter(filter, start, end);
      const decodedEvents = rawEvents.map(e => {
        return {
          blockNumber: e.blockNumber,
          log: contractInstanceForQueryingEvents.interface.parseLog({
            data: e.data,
            topics: e.topics
          })
        }
      });
      let csvString = "\"user\",\"amount\",\"blockNumber\"\n";
        for (const eventData of decodedEvents) {
          let amount;
          let user;
          if (eventData.log.args.amount !== undefined) {
            amount = eventData.log.args.amount;
            user = eventData.log.args.user;
          } else {
            if (second) {
              amount = eventData.log.args.wantTokenAmount;
              user = eventData.log.args.recipient;
            } else {
              amount = eventData.log.args.value;
              user = eventData.log.args.recipient;
            }
          }
          csvString += `\"${user}\",${hre.ethers.utils.formatUnits(amount, decimals)},${eventData.blockNumber}\n`;
        }
        await fsExtra.outputFile(csv, csvString);
        console.log(`CSV table stored in: ${csv}`);
    });
