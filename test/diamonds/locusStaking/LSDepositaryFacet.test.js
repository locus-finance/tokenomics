const { expect } = require("chai");
const networkHelpers = require("@nomicfoundation/hardhat-network-helpers");
const hre = require("hardhat");
const keccak256 = require('keccak256');
const { deployments, getNamedAccounts } = hre;
const { WEEK, withImpersonatedSigner, mintNativeTokens } = require("../../../deploy/helpers");

describe("LSDepositaryFacet", () => {
  let namedAccounts;
  let user1Balance;
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

    user1Balance = hre.ethers.utils.parseEther('10');
    
    // a real total reward acquired from onchain arbitrumOne
    totalReward = hre.ethers.utils.parseEther('100');
    
    await locusToken.mint(namedAccounts.user1, user1Balance);
    await locusToken.mint(namedAccounts.deployer, totalReward);

    await locusToken.approve(locusStaking.address, totalReward);
    await locusStaking.notifyRewardAmount(totalReward);

    await locusStaking.grantRole(namedAccounts.deployer, keccak256('DELAYED_SENDINGS_QUEUE_PROCESSOR_ROLE'));
    await locusStaking.grantRole(namedAccounts.deployer, keccak256('ALLOWED_TO_STAKE_FOR_ROLE'));
  
    await withImpersonatedSigner(namedAccounts.user1, async (personSigner) => {
      await mintNativeTokens(personSigner, "0x1000000000000000000000");
    });
  });

  it('should stake locus for someone successfully', async () => {
    await locusToken.mint(namedAccounts.deployer, user1Balance);
    await locusToken.approve(locusStaking.address, user1Balance);
    await locusStaking.stakeFor(namedAccounts.user1, user1Balance);
    expect(await locusStaking.balanceOf(namedAccounts.user1)).to.be.equal(user1Balance);
  });

  it('should stake locus successfully', async () => {
    await withImpersonatedSigner(namedAccounts.user1, async (personSigner) => {
      await locusToken.connect(personSigner).approve(locusStaking.address, user1Balance);
      await locusStaking.connect(personSigner).stake(user1Balance);
    });
    expect(await locusStaking.balanceOf(namedAccounts.user1)).to.be.equal(user1Balance);
  });

  // it('should claim rewards successfully', async () => {

  // });

  // it('should perform a withdrawal of locus through the queue successfully', async () => {
    
  // });

  // it('should sync wrapped balance of locus', async () => {
    
  // });
});