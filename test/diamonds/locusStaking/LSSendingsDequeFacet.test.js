const { expect } = require("chai");
const networkHelpers = require("@nomicfoundation/hardhat-network-helpers");
const hre = require("hardhat");
const keccak256 = require('keccak256');
const { deployments, getNamedAccounts } = hre;
const { WEEK, withImpersonatedSigner, mintNativeTokens } = require("../../../deploy/helpers");

describe("LSSendingsDequeFacet", () => {
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

  it('should perform an instant withdrawal', async () => {
    await withImpersonatedSigner(person, async (personSigner) => {
      await locusStaking.connect(personSigner).withdraw(personBalance, 1);
      const expectedBalance = personBalance.div('2');
      expect(await locusToken.balanceOf(person)).to.be.equal(expectedBalance);
      expect(await locusToken.balanceOf(namedAccounts.deployer)).to.be.equal(expectedBalance);
    });
  });

  it('should perform delayed withdrawal (1 week)', async () => {
    await withImpersonatedSigner(person, async (personSigner) => {
      await locusStaking.connect(personSigner).withdraw(personBalance, 2);
    });
    await networkHelpers.time.increase(WEEK);
    await locusStaking.processQueue();
    const feeTaken = personBalance.mul('3750').div('10000');
    expect(await locusToken.balanceOf(person)).to.be.equal(personBalance.sub(feeTaken));
    expect(await locusToken.balanceOf(namedAccounts.deployer)).to.be.equal(feeTaken);
  });

  it('should perform delayed withdrawal (2 weeks)', async () => {
    await withImpersonatedSigner(person, async (personSigner) => {
      await locusStaking.connect(personSigner).withdraw(personBalance, 3);
    });
    await networkHelpers.time.increase(2 * WEEK);
    await locusStaking.processQueue();
    const feeTaken = personBalance.mul('2500').div('10000');
    expect(await locusToken.balanceOf(person)).to.be.equal(personBalance.sub(feeTaken));
    expect(await locusToken.balanceOf(namedAccounts.deployer)).to.be.equal(feeTaken);
  });

  it('should perform delayed withdrawal (month)', async () => {
    await withImpersonatedSigner(person, async (personSigner) => {
      await locusStaking.connect(personSigner).withdraw(personBalance, 4);
    });
    await networkHelpers.time.increase(4 * WEEK);
    await locusStaking.processQueue();
    expect(await locusToken.balanceOf(person)).to.be.equal(personBalance);
    expect(await locusToken.balanceOf(namedAccounts.deployer)).to.be.equal('0');
  });

  it('should calculate APR correctly', async () => {
    expect(await locusStaking.getAPR()).to.be.equal(hre.ethers.BigNumber.from('166'));
  });

  it('should calculate APR in absolute value correctly', async () => {
    expect(await locusStaking.getAPRInAbsoluteValue()).to.be.equal(hre.ethers.BigNumber.from('16630107493559001'));
  });
});