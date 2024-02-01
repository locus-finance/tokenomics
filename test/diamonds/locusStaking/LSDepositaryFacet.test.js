const { expect } = require("chai");
const networkHelpers = require("@nomicfoundation/hardhat-network-helpers");
const hre = require("hardhat");
const keccak256 = require('keccak256');
const { deployments, getNamedAccounts } = hre;
const { WEEK, withImpersonatedSigner, mintNativeTokens } = require("../../../deploy/helpers");

describe("LSDepositaryFacet", () => {
  let namedAccounts;
  let person;
  let personBalance;
  let totalReward;

  let locusStaking;
  let locusToken;

  beforeEach(async () => {
    namedAccounts = await getNamedAccounts();
    await deployments.fixture([
      "deploy"
    ]);

    locusStaking = await hre.ethers.getContractAt(
      hre.names.internal.diamonds.locusStaking.interface,
      (await deployments.get(hre.names.internal.diamonds.locusStaking.proxy)).address
    );
    locusToken = await hre.ethers.getContractAt(
      hre.names.internal.diamonds.locusToken.interface,
      (await deployments.get(hre.names.internal.diamonds.locusToken.proxy)).address
    );

    // some random person
    person = "0x35AC85c14Be0acc68870348F33B150364aF35303";

    // a real total supply from onchain arbitrumOne
    personBalance = hre.ethers.BigNumber.from('1954286826623793992312644');
    
    // a real total reward acquired from onchain arbitrumOne
    totalReward = hre.ethers.BigNumber.from('32499999999999998323200');
    
    await locusToken.mint(person, personBalance);
    await locusToken.mint(namedAccounts.deployer, totalReward);

    await locusToken.approve(locusStaking.address, totalReward);
    await locusStaking.notifyRewardAmount(totalReward);

    await withImpersonatedSigner(person, async (personSigner) => {
      await mintNativeTokens(personSigner, "0x1000000000000000000000");
      await locusToken.connect(personSigner).approve(locusStaking.address, personBalance);
      await locusStaking.connect(personSigner).stake(personBalance);
    });

    await locusStaking.grantRole(namedAccounts.deployer, keccak256('DELAYED_SENDINGS_QUEUE_PROCESSOR_ROLE'));
  });

  it('should stake locus for someone successfully', async () => {
    
  });

  // it('should stake locus successfully', async () => {
    
  // });

  // it('should claim rewards successfully', async () => {

  // });

  // it('should perform a withdrawal of locus through the queue successfully', async () => {
    
  // });

  // it('should auto restake locus', async () => {
    
  // });

  // it('should sync wrapped balance of locus', async () => {
    
  // });
});