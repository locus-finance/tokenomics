const { expect } = require("chai");
const hre = require("hardhat");
const { deployments, getNamedAccounts } = hre;
const { withImpersonatedSigner, mintNativeTokens } = require("../deploy/helpers");

describe("DiamondLocusStaking", () => {
  let namedAccounts;
  let locusStaking;
  let locusToken;

  beforeEach(async () => {
    namedAccounts = await getNamedAccounts();
    await deployments.fixture([
      "debug"
    ]);

    locusStaking = await hre.ethers.getContractAt(
      hre.names.internal.diamonds.locusStaking.interface,
      (await deployments.get(hre.names.internal.diamonds.locusStaking.proxy)).address
    );
    locusToken = await hre.ethers.getContractAt(
      hre.names.internal.diamonds.locusToken.interface,
      (await deployments.get(hre.names.internal.diamonds.locusToken.proxy)).address
    );

    const person = "0x35AC85c14Be0acc68870348F33B150364aF35303";
    const personBalance = hre.ethers.BigNumber.from('1954286826623793992312644');
    const totalReward = hre.ethers.BigNumber.from('32499999999999998323200');
    await locusToken.mint(person, personBalance);

    await locusToken.mint(namedAccounts.deployer, totalReward);
    await locusToken.approve(locusStaking.address, totalReward);
    await locusStaking.notifyRewardAmount(totalReward);

    await withImpersonatedSigner(person, async (personSigner) => {
      await mintNativeTokens(personSigner, "0x1000000000000000000000");
      await locusToken.connect(personSigner).approve(locusStaking.address, personBalance);
      await locusStaking.connect(personSigner).stake(personBalance);
    });
  });

  it('should perform delayed withdrawal', async () => {
    
  });

  it('should perform calculate apr correctly', async () => {
    expect(await locusStaking.getAPR()).to.be.equal(hre.ethers.BigNumber.from('166'));
  });
});