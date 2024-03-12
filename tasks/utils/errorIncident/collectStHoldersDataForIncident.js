const fsExtra = require("fs-extra");
const { parseCSV } = require('../../../deploy/helpers');
const { types } = require("hardhat/config");

module.exports = (task) =>
  task(
    "collectIncident",
    "Collects full list of holders of stLOCUS\' that interacted with old staking at least once and their statistics.",
  )
    .addOptionalParam("includeLuckies", "A flag which decides if lucky sons of a guns should be included into statistics.", false, types.boolean)
    .addOptionalParam("midasCsv", "A csv table of Midas Claimers for cross referencing.", './resources/csv/midasHoldersSnapshot.csv', types.string)
    .addOptionalParam("stakingDeployBlock", "A block number from which events should be analyzed.", 154691110, types.int)
    .addOptionalParam("preErrorBlock", "A block number up to which events should be analyzed.", 188049440, types.int)
    .addOptionalParam("staking", "A file name that should be used when caching users with balances in old staking contract.", '', types.string)
    .addOptionalParam("locus", "Define a name or address of LOCUS token contract in hre.names.", '', types.string)
    .addOptionalParam("json", "A json full filename for collected data.", './resources/json/errorIncident/stLocusHoldersDataForIncidentAnalysis.json', types.string)
    .setAction(async ({ staking, stakingDeployBlock, preErrorBlock, json, midasCsv, locus, includeLuckies }, hre) => {
      if (!hre.names.isInitialized()) {
        await hre.names.gather();
      }
      const actualBlockNumber = (await hre.ethers.provider.getBlock()).number;
      if (actualBlockNumber !== preErrorBlock) {
        console.log(`WARNING: pre error balance would be calculated at block ${actualBlockNumber} nor than at pre error block ${preErrorBlock}!`);
      }

      const luckiesWhoSold = [
        "0x80b26ea44bab3d39516094b479b9565d9e80d4c6",
        "0x633f8aA64990C4f67a904b5Dd6bF5f03e49a5bAA",
        "0x91cca8cf03fdf510dade6649a25cc5ea6fc9bfb0",
        "0xad8da72fb6c0bc3b27a67dbe0daf8ad1476c8d20",
        "0x9345f4ac4288c921b0f6cea1cc9f7112baa2d71c"
      ].map(e => e.toLowerCase());

      const luckies = [
        "0x9b65dF1ADB9Ed083A9707F750f4D4211eDa92314",
        "0x80b26Ea44bAB3d39516094b479B9565D9E80d4C6",
        "0xD43f974FA5f9F3Ab8Aedb3121Dc614366D8fD24B",
        "0x633f8aA64990C4f67a904b5Dd6bF5f03e49a5bAA",
        "0x91CCA8cF03FDF510dAde6649a25cC5eA6FC9BFB0",
        "0xAD8da72fB6c0Bc3b27A67dBe0Daf8AD1476c8D20",
        "0x9Ca627DE8E06213671B6166717C8Cf876C1D7808",
        "0x9345f4AC4288c921b0F6ceA1cc9f7112baa2d71c",
        "0x58f791ade0e72334238677060E469d7b85456358",
        "0x05Be8D9FcB36647032fE5aee73fE0407f29aBAa8",
        "0x4afffa8f9ba82330daC0108825b9D4ce2Bd00aa6"
      ].map(e => e.toLowerCase());

      if (!luckiesWhoSold.every(e => luckies.includes(e))) {
        throw RuntimeError('Some of luckies who sold are not in the main list of luckies!');
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

      const luckiesInfo = {};
      for (const lucky of luckies) {
        luckiesInfo[lucky] = {
          address: lucky,
          expectedBalance: hre.ethers.utils.formatEther(await locusInstance.balanceOf(lucky)),
          soldAmount: luckiesWhoSold.includes(lucky) ? "HAS TO BE SPECIFIED MANUALLY" : hre.ethers.constants.Zero.toString()
        };
      }
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
        const formattedUserAddress = stakedEvent.args.user.toLowerCase(); 
        if (!includeLuckies && luckies.includes(formattedUserAddress)) continue;
        if (formattedUserAddress in users) {
          users[formattedUserAddress] = {
            address: formattedUserAddress,
            totalStaked: users[formattedUserAddress].totalStaked.add(stakedEvent.args.amount),
            totalSentOut: hre.ethers.constants.Zero,
            totalBalance: users[formattedUserAddress].totalBalance.add(stakedEvent.args.amount),
            sentOut: [],
            staked: users[formattedUserAddress].staked,
            isInMidasClaimers: users[formattedUserAddress].isInMidasClaimers,
            actualBalanceAtPreErrorBlock: users[formattedUserAddress].actualBalanceAtPreErrorBlock,
            actualEarnedAtPreErrorBlock: users[formattedUserAddress].actualEarnedAtPreErrorBlock,
            actualLocusBalanceAtPreError: users[formattedUserAddress].actualLocusBalanceAtPreError
          };
          users[formattedUserAddress].staked.push(hre.ethers.utils.formatEther(stakedEvent.args.amount));
        } else {
          const isInMidasClaimers = parsedMidasClaimers.includes(formattedUserAddress.toLowerCase());
          if (isInMidasClaimers) {
            totalUsersThatWereMidasClaimers++;
          }
          const actualBalanceAtPreErrorBlock = await stakingInstance.balanceOf(formattedUserAddress);
          const actualEarnedAtPreErrorBlock = await stakingInstance.earned(formattedUserAddress);
          const actualLocusBalanceAtPreError = await locusInstance.balanceOf(formattedUserAddress);
          users[formattedUserAddress] = {
            address: formattedUserAddress,
            totalStaked: stakedEvent.args.amount,
            totalSentOut: hre.ethers.constants.Zero,
            totalBalance: stakedEvent.args.amount,
            sentOut: [],
            staked: [hre.ethers.utils.formatEther(stakedEvent.args.amount)],
            isInMidasClaimers,
            actualBalanceAtPreErrorBlock: hre.ethers.utils.formatEther(actualBalanceAtPreErrorBlock),
            actualEarnedAtPreErrorBlock: hre.ethers.utils.formatEther(actualEarnedAtPreErrorBlock),
            actualLocusBalanceAtPreError: hre.ethers.utils.formatEther(actualLocusBalanceAtPreError)
          };
          totalEarned = totalEarned.add(actualEarnedAtPreErrorBlock);
          totalStaked = totalStaked.add(actualBalanceAtPreErrorBlock);
        }
      }

      for (const sentOutEvent of decodedSentOutEvents) {
        const formattedUserAddress = sentOutEvent.args.user.toLowerCase(); 
        if (!includeLuckies && luckies.includes(formattedUserAddress)) continue;
        if (formattedUserAddress in users) {
          users[formattedUserAddress].totalSentOut = users[formattedUserAddress].totalSentOut.add(sentOutEvent.args.amount);
          users[formattedUserAddress].totalBalance = users[formattedUserAddress].totalBalance.sub(sentOutEvent.args.amount);
          users[formattedUserAddress].sentOut.push(hre.ethers.utils.formatEther(sentOutEvent.args.amount));
        } else {
          throw new RuntimeError(`User have never staked: ${formattedUserAddress}`);
        }
      }

      for (const midasClaimer of parsedMidasClaimers) {
        if (!includeLuckies && luckies.includes(midasClaimer)) continue;
        if (!(midasClaimer in users)) {
          const actualBalanceAtPreErrorBlock = await stakingInstance.balanceOf(midasClaimer);
          const actualEarnedAtPreErrorBlock = await stakingInstance.earned(midasClaimer);
          const actualLocusBalanceAtPreError = await locusInstance.balanceOf(midasClaimer);
          
          totalEarned = totalEarned.add(actualEarnedAtPreErrorBlock);
          totalStaked = totalStaked.add(actualBalanceAtPreErrorBlock);
          users[midasClaimer] = {
            address: midasClaimer,
            totalStaked: hre.ethers.constants.Zero,
            totalSentOut: hre.ethers.constants.Zero,
            totalBalance: hre.ethers.constants.Zero,
            sentOut: [],
            staked: [],
            isInMidasClaimers: true,
            actualBalanceAtPreErrorBlock: hre.ethers.utils.formatEther(actualBalanceAtPreErrorBlock),
            actualEarnedAtPreErrorBlock: hre.ethers.utils.formatEther(actualEarnedAtPreErrorBlock),
            actualLocusBalanceAtPreError: hre.ethers.utils.formatEther(actualLocusBalanceAtPreError)
          }
          totalUsersThatWereMidasClaimers++;
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
        luckiesInfo,
        users,
        globalStats: {
          totalUsers: usersKeys.length,
          totalUsersThatWereMidasClaimers,
          balanceOfStakingContractInLocusAtPreError: hre.ethers.utils.formatEther(balanceOfStakingContractInLocusAtPreError),
          totalRewardAtPreError: hre.ethers.utils.formatEther(totalRewardAtPreError),
          totalStakedAtPreError: hre.ethers.utils.formatEther(totalStaked),
          totalEarnedAtPreError: hre.ethers.utils.formatEther(totalEarned),
          totalStakedAndRewardAtPreError: hre.ethers.utils.formatEther(totalRewardAtPreError.add(totalStaked)),
          difference: hre.ethers.utils.formatEther(balanceOfStakingContractInLocusAtPreError.sub(totalStaked.add(totalRewardAtPreError)))
        }
      }
      await fsExtra.outputFile(json, JSON.stringify(result));
      console.log(`${usersKeys.length} users collected, calculated statistics and data for, and saved.\n${totalUsersThatWereMidasClaimers} of them were Midas claimers.`)
      return result;
    });
