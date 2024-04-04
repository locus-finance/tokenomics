const networkHelpers = require("@nomicfoundation/hardhat-network-helpers");
const hre = require("hardhat");
const fsExtra = require('fs-extra');
const { expect } = require("chai");
const { deployments, getNamedAccounts } = hre;
const { WEEK, withImpersonatedSigner, mintNativeTokens } = require("../deploy/helpers");

// TO BE UTILIZED ONLY FOR HYPOTHESIS' TESTING!!!
// ALLOWED TO SMELL AND BE LITTERED
describe("AnyFixture", () => {

  // it('should test', async () => {
  //   await hre.names.gather();
  //   const staking = await hre.ethers.getContractAt(
  //     hre.names.internal.diamonds.locusXUsdTokensStaking.interface,
  //     "0x6C447230F098CDdB62f6AEaeEc25C27E8b90B25e"
  //   );
  //   console.log(await staking.getPrimitives());
  // });

  // it('should change balances', async () => {
  //   await hre.names.gather();
  //   const firstUser = "0xD43f974FA5f9F3Ab8Aedb3121Dc614366D8fD24B";

  //   const newLocusStaking = await hre.ethers.getContractAt(
  //     hre.names.internal.diamonds.autoreflectiveStaking.interface,
  //     "0xFCE625E69Bd4952417Fe628bC63D9AA0e4012684"
  //   );
  //   const balanceUser1 = await newLocusStaking.balanceOf(firstUser);

  //   console.log(hre.ethers.utils.formatEther(balanceUser1));
  // });

  // it('should calc apy - locus', async () => {
  //   await hre.names.gather();
  //   const newLocusStaking = await hre.ethers.getContractAt(
  //     hre.names.internal.diamonds.autoreflectiveStaking.interface,
  //     "0xFCE625E69Bd4952417Fe628bC63D9AA0e4012684"
  //   );
  //   const c = 32500;
  //   const rewardAdded = c / 30;

  //   const b = 1;
  //   const ts = parseFloat(hre.ethers.utils.formatEther(await newLocusStaking.totalSupply()));
  //   const yearlyRewardAdded = rewardAdded * 365;
  //   const newB = b + (b / ts) * yearlyRewardAdded;

  //   console.log(`b: ${b}`);
  //   console.log(`newB: ${newB}`);
  //   const apr = (newB - b) / ((b + newB) / 2);
  //   console.log(`nominal rate: ${apr}`);
  //   const apy = 100 * (((1 + apr / 365) ** 365) - 1);
  //   console.log(`APY: ${apy}`);
  // });

  // it('should calc stakingrewards apy - xARB', async () => {
  //   await hre.names.gather();
  //   const staking = await hre.ethers.getContractAt(
  //     hre.names.internal.diamonds.locusXArbTokensStaking.interface,
  //     "0x6C447230F098CDdB62f6AEaeEc25C27E8b90B25e"
  //   );

  //   const xArbToUsd = 1.162550462795565;//1.03;
  //   const locusToUsdPrice = 0.994897;//1.02;
  //   const rewardAdded = 3000;
  //   const ts = parseFloat(hre.ethers.utils.formatUnits(await staking.totalSupply(), 6));

  //   const yearlyRewardAdded = rewardAdded * 12;
  //   const yearlyRewardAddedEquivalentInUsd = yearlyRewardAdded * locusToUsdPrice;

  //   const b = 1;
  //   const share = b / ts;
    
  //   console.log(`yearly reward in usd: ${yearlyRewardAddedEquivalentInUsd}`);

  //   const bUsd = b * xArbToUsd;
  //   const newBUsd = bUsd + share * yearlyRewardAddedEquivalentInUsd;

  //   console.log(`total supply: ${ts}`);
  //   console.log(`share: ${share}`);
  //   console.log(`balance in usd: ${bUsd}`);
  //   console.log(`new balance in usd: ${newBUsd}`);
  //   const apy = 100 * ((newBUsd - bUsd) / bUsd);
  //   console.log(`APY: ${apy}`);
  // });

  // it('should calc stakingrewards apy - xUSD', async () => {
  //   await hre.names.gather();
  //   const staking = await hre.ethers.getContractAt(
  //     hre.names.internal.diamonds.locusXArbTokensStaking.interface,
  //     "0x6390743ccb7928581F61427652330a1aEfD885c2"
  //   );

  //   const xUsdToUsd = 1.03;
  //   const locusToUsdPrice = 1.02;
  //   const rewardAdded = 7000;
  //   const ts = parseFloat(hre.ethers.utils.formatUnits(await staking.totalSupply(), 6));

  //   const yearlyRewardAdded = rewardAdded * 12;
  //   const yearlyRewardAddedEquivalentInUsd = yearlyRewardAdded * locusToUsdPrice;

  //   const b = 1;
  //   const share = b / ts;
    
  //   console.log(`yearly reward in usd: ${yearlyRewardAddedEquivalentInUsd}`);

  //   const bUsd = b * xUsdToUsd;
  //   const newBUsd = bUsd + share * yearlyRewardAddedEquivalentInUsd;

  //   console.log(`total supply: ${ts}`);
  //   console.log(`share: ${share}`);
  //   console.log(`balance in usd: ${bUsd}`);
  //   console.log(`new balance in usd: ${newBUsd}`);
  //   const apy = 100 * ((newBUsd - bUsd) / bUsd);
  //   console.log(`APY: ${apy}`);
  // });

  // it('should gather withdraws deque at the time before the incident', async () => {
  //   await hre.names.gather();
  //   const oldStakingAddress = "0xEcc5e0c19806Cf47531F307140e8b042D5Afb952";
  //   const newStakingAddress = "0xFCE625E69Bd4952417Fe628bC63D9AA0e4012684";

  //   const stakingInstance = await hre.ethers.getContractAt(
  //     hre.names.internal.diamonds.locusStaking.interface,
  //     newStakingAddress
  //   );

  //   console.log((await stakingInstance.getDequeSize()).toString());
  //   const deque = (await stakingInstance.getSendingsDeque())
  //     .map(e => {
  //       return {
  //         receiver: e.receiver,
  //         sendingToken: e.sendingToken,
  //         amount: hre.ethers.utils.formatEther(e.amount),
  //         dueToTimestamp: e.dueToTimestamp.toString(),
  //         dueToDuration: e.dueToDuration,
  //         dueToDate: (new Date(parseInt(e.dueToTimestamp) * 1000)).toUTCString()
  //       };
  //     })
  //     .sort((a, b) => parseInt(a.dueToTimestamp) - parseInt(b.dueToTimestamp));

  //   fsExtra.writeJSON("./resources/json/errorIncident/withdrawsDequePostErrorInNewStaking.json", deque);
  // });

  // xit('should migrate successfully', async () => {
  //   await hre.names.gather();

  //   const oldStakingAddress = "0xEcc5e0c19806Cf47531F307140e8b042D5Afb952";
  //   const newStakingAddress = "0xFCE625E69Bd4952417Fe628bC63D9AA0e4012684";
  //   const locusAddress = "0xe1d3495717f9534Db67A6A8d4940Dd17435b6A9E";

  //   const locusInstance = await hre.ethers.getContractAt(
  //     hre.names.internal.diamonds.locusToken.interface,
  //     locusAddress
  //   );
  //   const newStakingInstance = await hre.ethers.getContractAt(
  //     hre.names.internal.diamonds.autoreflectiveStaking.interface,
  //     newStakingAddress
  //   );

  //   const { deployer } = await getNamedAccounts();

  //   const incidentDataWithLuckies = await fsExtra.readJSON('./resources/json/errorIncident/stLocusHoldersDataForIncidentAnalysisWithLuckies.json');
  //   const incidentData = await fsExtra.readJSON('./resources/json/errorIncident/stLocusHoldersDataForIncidentAnalysisWithoutLuckies.json');

  //   const usersForCalldata = [];
  //   const stLocusAmountsForCalldata = [];
  //   const locusAmountsForCalldata = [];
  //   const usersKeys = Object.keys(incidentData.users);
  //   const oldDeployerBalance = await locusInstance.balanceOf(deployer);

  //   for (let i = 0; i < usersKeys.length; i++) {
  //     const user = usersKeys[i];
  //     const balance = hre.ethers.utils.parseEther(incidentData.users[user].actualBalanceAtPreErrorBlock);
  //     const earned = hre.ethers.utils.parseEther(incidentData.users[user].actualEarnedAtPreErrorBlock);
  //     const locusBalance = hre.ethers.utils.parseEther(incidentData.users[user].actualLocusBalanceAtPreError);
  //     const amount = balance.add(earned);
  //     if (amount.eq(0)) continue;
  //     usersForCalldata.push(user);
  //     stLocusAmountsForCalldata.push(amount);
  //     locusAmountsForCalldata.push(locusBalance);
  //   }

  //   const balanceOfStakingContractInLocusAtPreError = hre.ethers.utils.parseEther(incidentData.globalStats.balanceOfStakingContractInLocusAtPreError);
  //   const totalReward = hre.ethers.utils.parseEther(incidentData.globalStats.totalRewardAtPreError);
  //   const totalStaked = hre.ethers.utils.parseEther(incidentData.globalStats.totalStakedAtPreError);
  //   const totalEarned = hre.ethers.utils.parseEther(incidentData.globalStats.totalEarnedAtPreError);
  //   const differenceInIncidentDataWithLuckies = hre.ethers.utils.parseEther(incidentDataWithLuckies.globalStats.difference);
  //   const differenceInIncidentDataWithoutLuckies = hre.ethers.utils.parseEther(incidentData.globalStats.difference);

  //   const totalStakedAndEarned = totalStaked.add(totalEarned);
  //   const luckiesBalances = differenceInIncidentDataWithoutLuckies.sub(differenceInIncidentDataWithLuckies);

  //   const expectedAutocratBalance = balanceOfStakingContractInLocusAtPreError.sub(totalStakedAndEarned).sub(luckiesBalances);
  //   const unassignedAndUndistributedRewards = totalReward.sub(totalEarned);
  //   const actualOldStakingBalance = await locusInstance.balanceOf(oldStakingAddress);
  //   const additionalMintToDistributeToUsers = totalStakedAndEarned.sub(actualOldStakingBalance);

  //   expect(differenceInIncidentDataWithLuckies).to.be.equal(expectedAutocratBalance.sub(unassignedAndUndistributedRewards));

  //   await locusInstance.mint(oldStakingAddress, additionalMintToDistributeToUsers);
  //   await locusInstance.mint(deployer, expectedAutocratBalance);

  //   const parts = 10;
  //   console.log(`Users to liquidate incident for: ${usersForCalldata.length}`);
  //   let window = Math.floor(usersForCalldata.length / parts) + 1;
  //   console.log(`Groupings of users: ${window}`);
  //   for (let offset = 0; offset < usersForCalldata.length; offset += window) {
  //     const start = offset;
  //     let end = start + window;
  //     if (end > usersForCalldata.length) end = usersForCalldata.length;
  //     console.log(`Liquidating the incident consequences for a group of users numbered from ${start} to ${end}.`);
  //     const usersPart = usersForCalldata.slice(start, end);
  //     const stLocusAmountsPart = stLocusAmountsForCalldata.slice(start, end);
  //     const locusAmountsPart = locusAmountsForCalldata.slice(start, end);
  //     await locusInstance.liquidateIncident(
  //       oldStakingAddress, 
  //       newStakingAddress,
  //       usersPart,
  //       stLocusAmountsPart,
  //       locusAmountsPart
  //     );
  //     console.log(`Group ${start}-${end} has been cleared`);
  //   }

  //   for (let i = 0; i < usersForCalldata.length; i++) {
  //     expect(await newStakingInstance.balanceOf(usersForCalldata[i])).to.be.equal(stLocusAmountsForCalldata[i]);
  //   }
  //   expect(await locusInstance.balanceOf(oldStakingAddress)).to.be.equal(hre.ethers.constants.Zero);
  //   expect((await locusInstance.balanceOf(deployer)).sub(oldDeployerBalance)).to.be.equal(expectedAutocratBalance);
  // });

  // xit('Successful collection of stLOCUS holders.', async () => {
  //   await hre.run('collectIncident', {
  //     staking: "0xEcc5e0c19806Cf47531F307140e8b042D5Afb952",
  //     locus: "0xe1d3495717f9534Db67A6A8d4940Dd17435b6A9E",
  //     includeLuckies: true,
  //     json: "./resources/json/errorIncident/stLocusHoldersDataForIncidentAnalysisWithLuckies.json"
  //   });
  //   await hre.run('collectIncident', {
  //     staking: "0xEcc5e0c19806Cf47531F307140e8b042D5Afb952",
  //     locus: "0xe1d3495717f9534Db67A6A8d4940Dd17435b6A9E",
  //     includeLuckies: false,
  //     json: "./resources/json/errorIncident/stLocusHoldersDataForIncidentAnalysisWithoutLuckies.json"
  //   });
  // });

  // xit('Successful migrate from old to new staking', async () => {
  //   hre.tracer.nameTags = {};
  //   await hre.run('migrateBalances', {
  //     old: "0xEcc5e0c19806Cf47531F307140e8b042D5Afb952",
  //     latest: "0xFCE625E69Bd4952417Fe628bC63D9AA0e4012684"
  //   });
  //   const newLocusStaking = await hre.ethers.getContractAt(
  //     hre.names.internal.diamonds.autoreflectiveStaking.interface,
  //     "0xFCE625E69Bd4952417Fe628bC63D9AA0e4012684"
  //   );
  //   const parsed = await parseCSV(["address", "balance"], "./resources/csv/oldStakingDepositHolders.csv");
  //   for (let i = 0; i < parsed.length; i++) {
  //     const holder = parsed[i];
  //     expect(await newLocusStaking.balanceOf(holder.address)).to.be.gt(0);
  //     console.log(`expect - ${holder.address} #${i} of ${parsed.length}`);
  //   }
  // });

  // xit('should', async () => {
  //   const locusStaking = await hre.ethers.getContractAt(
  //     hre.names.internal.diamonds.locusStaking.interface,
  //     "0xEcc5e0c19806Cf47531F307140e8b042D5Afb952"
  //   );
  //   // const dequeSize = parseInt((await locusStaking.getDequeSize()).toString());
  //   // const user = "0x43eB6fE17D7CC599AaC8b095B5CA412f4C72a2DD";
  //   // for (let i = 0; i < dequeSize; i++) {
  //   //   const delayedSending = await locusStaking.getDelayedSending(i);
  //   //   console.log(delayedSending.receiver);
  //   // }
  //   const user2 = "0xF70fEAa153A0Ffc391525c1226d6E0f00eDF9974";
  //   const amount = hre.ethers.utils.parseUnits("1.1", 6);
  //   await withImpersonatedSigner(user2, async (user2Signer) => {
  //     await locusStaking.connect(user2Signer).withdraw(amount, 4);
  //   });
  //   expect(true).to.be.true;
  // });

  // xit('should work 2', async () => {
  //   const locusStaking = await hre.ethers.getContractAt(
  //     hre.names.internal.diamonds.locusStaking.interface,
  //     "0xEcc5e0c19806Cf47531F307140e8b042D5Afb952"
  //   );
  //   const locusToken = await hre.ethers.getContractAt(
  //     hre.names.internal.diamonds.locusToken.interface,
  //     "0xe1d3495717f9534Db67A6A8d4940Dd17435b6A9E"
  //   );

  //   const format = (apr) => {
  //     apr /= 100;
  //     const compoundingPeriodsPerYear = 12;
  //     const r = apr * 12 / 100;
  //     const apy = Math.pow(1 + r / compoundingPeriodsPerYear, compoundingPeriodsPerYear) - 1;
  //     return apy * 100;
  //   }

  //   const toBurn = hre.ethers.utils.parseEther('97500').sub(hre.ethers.utils.parseEther('65000'));

  //   const oldAPR = parseInt((await locusStaking.getAPR()).toString())
  //   console.log(`Unformatted old apr: ${oldAPR}`);
  //   console.log(`Old apr: ${format(oldAPR)}`);
  //   console.log(`To burn: ${toBurn.toString()}`);

  //   const admin = "0x729F2222aaCD99619B8B660b412baE9fCEa3d90F";
  //   await withImpersonatedSigner(admin, async (adminSigner) => {
  //     const was = (await locusToken.balanceOf(locusStaking.address)).sub(await locusStaking.totalSupply());
  //     console.log(`Was: ${hre.ethers.utils.formatEther(was)}`);
  //     await locusToken.connect(adminSigner).burn(locusStaking.address, toBurn);
  //     const now = (await locusToken.balanceOf(locusStaking.address)).sub(await locusStaking.totalSupply());
  //     console.log(`Now: ${hre.ethers.utils.formatEther(now)}`);
  //     console.log(`Diff: ${hre.ethers.utils.formatEther(was.sub(now))}`);

  //     const pBefore = await locusStaking.getPrimitives();
  //     console.log(`rate before: ${pBefore.rewardRate.toString()}`);
  //     await locusStaking.connect(adminSigner).TO_BE_REMOVED_setDuration(WEEK * 4, toBurn, toBurn);
  //     const pAfter = await locusStaking.getPrimitives();
  //     console.log(`rate after: ${pAfter.rewardRate.toString()}`);
  //   });

  //   const newAPR = parseInt((await locusStaking.getAPR()).toString());
  //   console.log(`Unformatted new apr: ${newAPR}`);
  //   console.log(`New apr: ${format(newAPR)}`);
  // });

  // xit('should work', async () => {
  //   const locusStaking = await hre.ethers.getContractAt(
  //     hre.names.internal.diamonds.locusStaking.interface,
  //     "0xEcc5e0c19806Cf47531F307140e8b042D5Afb952"
  //   );
  //   const locusToken = await hre.ethers.getContractAt(
  //     hre.names.internal.diamonds.locusToken.interface,
  //     "0xe1d3495717f9534Db67A6A8d4940Dd17435b6A9E"
  //   );
  //   const person = "0x35AC85c14Be0acc68870348F33B150364aF35303";
  //   const personBalance = await locusToken.balanceOf(person);
  //   console.log(personBalance.toString());
  //   console.log((await locusStaking.balanceOf(person)).toString());
  //   console.log((await locusStaking.getCurrentFeeBps(person)).toString());
  //   console.log('---');
  //   await withImpersonatedSigner(person, async (personSigner) => {
  //     await mintNativeTokens(personSigner, "0x1000000000000000000000");
  //     await locusToken.connect(personSigner).approve(locusStaking.address, personBalance);
  //     await locusStaking.connect(personSigner).stake(personBalance);
  //     await locusStaking.connect(personSigner).withdraw(personBalance);
  //   });
  //   console.log((await locusToken.balanceOf(person)).toString());
  //   console.log((await locusStaking.balanceOf(person)).toString());
  // });

  // xit('test', async () => {
  //   const locusStaking = await hre.ethers.getContractAt(
  //     hre.names.internal.diamonds.locusStaking.interface,
  //     "0xEcc5e0c19806Cf47531F307140e8b042D5Afb952"
  //   );
  //   console.log((await locusStaking.totalSupply()).toString());
  //   console.log((await locusStaking.getRewardForDuration()).toString());
  // });

  // xit('Successful run mint and notifyRewardAmount', async () => {
  //   await deployments.fixture(['debug']);
  //   await hre.run('provide');
  // });

  it('Successful run queue', async () => {
    await hre.run('queue', {
      diamond: "0x6390743ccb7928581F61427652330a1aEfD885c2"
    });
  });

  // xit("Successful fixture performance", async () => {
  //   await deployments.fixture(['debug']);
  //   const { deployer } = await getNamedAccounts();
  //   const locusStaking = await hre.ethers.getContractAt(
  //     hre.names.internal.diamonds.locusStaking.interface,
  //     (await deployments.get(hre.names.internal.diamonds.locusStaking.proxy)).address
  //   );
  //   const locusToken = await hre.ethers.getContractAt(
  //     hre.names.internal.diamonds.locusToken.interface,
  //     (await deployments.get(hre.names.internal.diamonds.locusToken.proxy)).address
  //   );
  //   const amount = hre.ethers.utils.parseEther('10');
  //   await locusToken.mint(deployer, amount);
  //   await locusToken.approve(locusStaking.address, amount);
  //   await locusStaking.stake(amount);

  //   console.log('offchain');
  //   console.log((await locusToken.balanceOf(deployer)).toString());
  //   console.log((await locusStaking.balanceOf(deployer)).toString());
  //   console.log('---');
  //   await locusStaking.withdraw(amount);
  //   console.log('***');
  //   console.log((await locusToken.balanceOf(deployer)).toString());

  //   // await networkHelpers.time.increase(WEEK + 1);
  //   // console.log((await locusStaking.getCurrentFeeBps(deployer)).toString());
  //   // await networkHelpers.time.increase(WEEK * 2);
  //   // console.log((await locusStaking.getCurrentFeeBps(deployer)).toString());
  //   // await networkHelpers.time.increase(WEEK);
  //   // console.log((await locusStaking.getCurrentFeeBps(deployer)).toString());
  // });
});