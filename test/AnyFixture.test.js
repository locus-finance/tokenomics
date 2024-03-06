const networkHelpers = require("@nomicfoundation/hardhat-network-helpers");
const hre = require("hardhat");
const { expect } = require("chai");
const { deployments, getNamedAccounts } = hre;
const { WEEK, withImpersonatedSigner, mintNativeTokens } = require("../deploy/helpers");

// TO BE UTILIZED ONLY FOR HYPOTHESIS' TESTING!!!
// ALLOWED TO SMELL AND BE LITTERED
describe("AnyFixture", () => {

  it('should', async () => {
    const staking = await hre.ethers.getContractAt(
      "DiamondAutoreflectiveStaking",
      "0x9e3b9caed1ed5a838dd04b35a16333c631ea94a7"
    );
    console.log((await staking.balanceOf("0x729f2222aacd99619b8b660b412bae9fcea3d90f")).toString());
  });

  // xit('should test fixture', async () => {
  //   await deployments.fixture(['deploy']);
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