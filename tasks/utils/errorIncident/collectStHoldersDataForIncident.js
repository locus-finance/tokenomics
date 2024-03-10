const fsExtra = require("fs-extra");
const { parseCSV } = require('../../../deploy/helpers');
module.exports = (task) =>
  task(
    "collectIncident",
    "Collects full list of holders of stLOCUS\' that interacted with old staking at least once and their statistics.",
  )
    .addOptionalParam("midasCsv", "A csv table of Midas Claimers for cross referencing.", './resources/csv/midasHoldersSnapshot.csv', types.string)
    .addOptionalParam("stakingDeployBlock", "A block number from which events should be analyzed.", 154691110, types.int)
    .addOptionalParam("preErrorBlock", "A block number up to which events should be analyzed.", 188021861, types.int)
    .addOptionalParam("staking", "A file name that should be used when caching users with balances in old staking contract.", '', types.string)
    .addOptionalParam("locus", "Define a name or address of LOCUS token contract in hre.names.", '', types.string)
    .addOptionalParam("json", "A json full filename for collected data.", './resources/json/errorIncident/stLocusHoldersDataForIncidentAnalysis.json', types.string)
    .setAction(async ({ staking, stakingDeployBlock, preErrorBlock, json, midasCsv, locus }, hre) => {
      if (!hre.names.isInitialized()) {
        await hre.names.gather();
      }

      const actualBlockNumber = (await hre.ethers.provider.getBlock()).number; 
      if (actualBlockNumber !== preErrorBlock) {
        console.log(`WARNING: pre error balance would be calculated at block ${actualBlockNumber} nor than at pre error block ${preErrorBlock}!`);
      }

      const stakingAddress = staking === '' ? (await hre.deployments.get(hre.names.internal.diamonds.locusStaking.proxy)).address : staking;
      const stakingInstance = await hre.ethers.getContractAt(
        hre.names.internal.diamonds.locusStaking.interface,
        stakingAddress
      );

      const locusAddress = locus !== '' ? locus : (await hre.deployments.get(hre.names.internal.diamonds.locusToken.proxy)).address
      const locusInstance = await hre.ethers.getContractAt(
        hre.names.internal.diamonds.locusToken.interface,
        locusAddress
      );

      const users = {};

      const eventsAbi = [
        "event Staked(address indexed user,uint256 indexed amount)",
        "event SentOut(address indexed token,address indexed user, uint256 indexed amount, uint256 feesTaken)"
      ];
      const contractInstanceForQueryingEvents = new hre.ethers.Contract(stakingAddress, eventsAbi, hre.ethers.provider);

      const stakedFilter = contractInstanceForQueryingEvents.filters.Staked(null, null);
      const sentOutFilter = contractInstanceForQueryingEvents.filters.SentOut(null, null, null, null);

      const rawStakedEvents = await contractInstanceForQueryingEvents.queryFilter(stakedFilter, stakingDeployBlock, preErrorBlock);
      const rawSentOutEvents = await contractInstanceForQueryingEvents.queryFilter(sentOutFilter, stakingDeployBlock, preErrorBlock);

      const decodedSentOutEvents = rawSentOutEvents.map(e => contractInstanceForQueryingEvents.interface.parseLog({
        data: e.data,
        topics: e.topics
      }));
      const decodedStakedEvents = rawStakedEvents.map(e => contractInstanceForQueryingEvents.interface.parseLog({
        data: e.data,
        topics: e.topics
      }));

      const parsedMidasClaimers = (await parseCSV(["HolderAddress"], midasCsv)).map(e => e.HolderAddress.toLowerCase());
      let totalUsersThatWereMidasClaimers = 0;
      let totalEarned = hre.ethers.constants.Zero;
      let totalStaked = hre.ethers.constants.Zero;

      for (const stakedEvent of decodedStakedEvents) {
        if (stakedEvent.args.user in users) {
          users[stakedEvent.args.user] = {
            address: stakedEvent.args.user,
            totalStaked: users[stakedEvent.args.user].totalStaked.add(stakedEvent.args.amount),
            totalSentOut: hre.ethers.constants.Zero,
            totalBalance: users[stakedEvent.args.user].totalBalance.add(stakedEvent.args.amount),
            sentOut: [],
            staked: users[stakedEvent.args.user].staked,
            isInMidasClaimers: users[stakedEvent.args.user].isInMidasClaimers,
            actualBalanceAtPreErrorBlock: users[stakedEvent.args.user].actualBalanceAtPreErrorBlock,
            actualEarnedAtPreErrorBlock: users[stakedEvent.args.user].actualEarnedAtPreErrorBlock
          };
          users[stakedEvent.args.user].staked.push(hre.ethers.utils.formatEther(stakedEvent.args.amount));
        } else {
          const isInMidasClaimers = parsedMidasClaimers.includes(stakedEvent.args.user.toLowerCase());
          if (isInMidasClaimers) {
            totalUsersThatWereMidasClaimers++;
          }
          const actualBalanceAtPreErrorBlock = await stakingInstance.balanceOf(stakedEvent.args.user);
          const actualEarnedAtPreErrorBlock = await stakingInstance.earned(stakedEvent.args.user);
          users[stakedEvent.args.user] = {
            address: stakedEvent.args.user,
            totalStaked: stakedEvent.args.amount,
            totalSentOut: hre.ethers.constants.Zero,
            totalBalance: stakedEvent.args.amount,
            sentOut: [],
            staked: [hre.ethers.utils.formatEther(stakedEvent.args.amount)],
            isInMidasClaimers,
            actualBalanceAtPreErrorBlock: hre.ethers.utils.formatEther(actualBalanceAtPreErrorBlock),
            actualEarnedAtPreErrorBlock: hre.ethers.utils.formatEther(actualEarnedAtPreErrorBlock)
          };
          totalEarned = totalEarned.add(actualEarnedAtPreErrorBlock);
          totalStaked = totalStaked.add(actualBalanceAtPreErrorBlock);
        }
      }

      for (const sentOutEvent of decodedSentOutEvents) {
        if (sentOutEvent.args.user in users) {
          users[sentOutEvent.args.user].totalSentOut = users[sentOutEvent.args.user].totalSentOut.add(sentOutEvent.args.amount);
          users[sentOutEvent.args.user].totalBalance = users[sentOutEvent.args.user].totalBalance.sub(sentOutEvent.args.amount);
          users[sentOutEvent.args.user].sentOut.push(hre.ethers.utils.formatEther(sentOutEvent.args.amount));
        } else {
          throw new RuntimeError(`User have never staked: ${sentOutEvent.args.user}`);
        }
      }

      const usersKeys = Object.keys(users);
      for (let i = 0; i < usersKeys.length; i++) {
        users[usersKeys[i]].totalStaked = hre.ethers.utils.formatEther(users[usersKeys[i]].totalStaked);
        users[usersKeys[i]].totalSentOut = hre.ethers.utils.formatEther(users[usersKeys[i]].totalSentOut);
        users[usersKeys[i]].totalBalance = hre.ethers.utils.formatEther(users[usersKeys[i]].totalBalance);
      }

      const balanceOfStakingContractInLocusAtPreError = await locusInstance.balanceOf(stakingAddress);
      const totalRewardAtPreError = await stakingInstance.getTotalReward();
      const result = {
        users,
        globalStats: {
          totalUsers: usersKeys.length,
          totalUsersThatWereMidasClaimers,
          balanceOfStakingContractInLocusAtPreError: hre.ethers.utils.formatEther(balanceOfStakingContractInLocusAtPreError),
          totalRewardAtPreError: hre.ethers.utils.formatEther(totalRewardAtPreError),
          totalStakedAtPreError: hre.ethers.utils.formatEther(totalStaked),
          totalEarnedAtPreError: hre.ethers.utils.formatEther(totalEarned),
          totalEarnedAndStakedAtPreError: hre.ethers.utils.formatEther(totalEarned.add(totalStaked)),
          difference: hre.ethers.utils.formatEther(balanceOfStakingContractInLocusAtPreError.sub(totalEarned.add(totalStaked).add(totalRewardAtPreError)))
        }
      }
      await fsExtra.outputFile(json, JSON.stringify(result));
      console.log(`${usersKeys.length} users collected, calculated statistics and data for, and saved.\n${totalUsersThatWereMidasClaimers} of them were Midas claimers.`)
      return result;
    });
