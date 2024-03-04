const { expect } = require("chai");
const networkHelpers = require("@nomicfoundation/hardhat-network-helpers");
const hre = require("hardhat");
const { deployments, getNamedAccounts } = hre;
const { WEEK, withImpersonatedSigner, mintNativeTokens, DAY } = require("../../../deploy/helpers");

describe("ASDepositaryFacet", () => {
  const totalReward = hre.ethers.utils.parseEther('32500');
  const dust = hre.ethers.utils.parseEther('0.001');
  
  let namedAccounts;
  let user1Balance;
  let user1Signer;

  let autoreflectiveStaking;
  let mockToken;

  beforeEach(async () => {
    namedAccounts = await getNamedAccounts();
    user1Signer = (await hre.ethers.getSigners())[1];
    await deployments.fixture([
      "autoreflectiveStakingFixture"
    ]);

    autoreflectiveStaking = await hre.ethers.getContractAt(
      hre.names.internal.diamonds.autoreflectiveStaking.interface,
      (await deployments.get(hre.names.internal.diamonds.autoreflectiveStaking.proxy)).address
    );
    mockToken = await hre.ethers.getContractAt(
      hre.names.internal.mockLocus,
      (await deployments.get(hre.names.internal.mockLocus)).address
    );
    user1Balance = hre.ethers.utils.parseEther('10');
    await mockToken.mint(namedAccounts.deployer, user1Balance);
    await mockToken.mint(namedAccounts.deployer, totalReward.add(dust));
  });

  it('should transfer', async () => {
    await mockToken.approve(autoreflectiveStaking.address, user1Balance);
    await autoreflectiveStaking.stake(user1Balance);

    console.log(`pre transfer u1: ${hre.ethers.utils.formatEther((await autoreflectiveStaking.balanceOf(namedAccounts.user1)).toString())}`);
    console.log(`pre transfer d: ${hre.ethers.utils.formatEther((await autoreflectiveStaking.balanceOf(namedAccounts.deployer)).toString())}`);
    await autoreflectiveStaking.transfer(namedAccounts.user1, user1Balance);
    console.log(`post transfer u1: ${hre.ethers.utils.formatEther((await autoreflectiveStaking.balanceOf(namedAccounts.user1)).toString())}`);
    console.log(`post transfer d: ${hre.ethers.utils.formatEther((await autoreflectiveStaking.balanceOf(namedAccounts.deployer)).toString())}`);
    
    console.log('From one pocket to another...');
    await autoreflectiveStaking.connect(user1Signer).transfer(namedAccounts.deployer, user1Balance.div(2));
    console.log(`pre increase u1: ${hre.ethers.utils.formatEther((await autoreflectiveStaking.balanceOf(namedAccounts.user1)).toString())}`);
    console.log(`pre increase d: ${hre.ethers.utils.formatEther((await autoreflectiveStaking.balanceOf(namedAccounts.deployer)).toString())}`);
    
    console.log("pre increase");
    await networkHelpers.time.increase(WEEK);
    console.log("post increase");
    console.log(`post increase u1: ${hre.ethers.utils.formatEther((await autoreflectiveStaking.balanceOf(namedAccounts.user1)).toString())}`);
    console.log(`post increase d: ${hre.ethers.utils.formatEther((await autoreflectiveStaking.balanceOf(namedAccounts.deployer)).toString())}`);
    await autoreflectiveStaking.transfer(namedAccounts.user1, await autoreflectiveStaking.balanceOf(namedAccounts.deployer));    
    console.log(`post increase 2 transfer u1: ${hre.ethers.utils.formatEther((await autoreflectiveStaking.balanceOf(namedAccounts.user1)).toString())}`);
    console.log(`post increase 2 transfer d: ${hre.ethers.utils.formatEther((await autoreflectiveStaking.balanceOf(namedAccounts.deployer)).toString())}`);
    console.log("End shuffling");

    await autoreflectiveStaking.connect(user1Signer).transfer(namedAccounts.user2, user1Balance.div(2));
    console.log(`post increase 3 transfer u2: ${hre.ethers.utils.formatEther((await autoreflectiveStaking.balanceOf(namedAccounts.user2)).toString())}`);
    console.log(`post increase 3 transfer u1: ${hre.ethers.utils.formatEther((await autoreflectiveStaking.balanceOf(namedAccounts.user1)).toString())}`);
    console.log(`post increase 3 transfer d: ${hre.ethers.utils.formatEther((await autoreflectiveStaking.balanceOf(namedAccounts.deployer)).toString())}`);
  });

  it('should reflect rewards', async () => {
    const stakeAmount = user1Balance;
    const rewardAmount = hre.ethers.utils.parseEther('32500').div(30);
    await mockToken.approve(autoreflectiveStaking.address, stakeAmount.add(rewardAmount));
    await autoreflectiveStaking.stake(stakeAmount);
    
    await autoreflectiveStaking.transfer(namedAccounts.user1, stakeAmount.div(4));

    console.log(`pre u1: ${hre.ethers.utils.formatEther((await autoreflectiveStaking.balanceOf(namedAccounts.user1)).toString())}`);
    console.log(`pre d: ${hre.ethers.utils.formatEther((await autoreflectiveStaking.balanceOf(namedAccounts.deployer)).toString())}`);
    await autoreflectiveStaking.notifyRewardAmount(rewardAmount);
    console.log(`post u1: ${hre.ethers.utils.formatEther((await autoreflectiveStaking.balanceOf(namedAccounts.user1)).toString())}`);
    console.log(`post d: ${hre.ethers.utils.formatEther((await autoreflectiveStaking.balanceOf(namedAccounts.deployer)).toString())}`);
  });

  it('should stake and withdraw successfully for month', async () => {
    const daysInMonth = 30;
    const stakeAmount = user1Balance;
    const rewardAmount = totalReward.div(daysInMonth).add(1);
    const user1Stake = stakeAmount.div(4);
    const deployerStake = stakeAmount.sub(user1Stake);

    await mockToken.approve(autoreflectiveStaking.address, stakeAmount.add(totalReward).add(dust));
    await autoreflectiveStaking.stake(stakeAmount);
    await autoreflectiveStaking.transfer(namedAccounts.user1, user1Stake);

    expect(await autoreflectiveStaking.balanceOf(namedAccounts.user1)).to.be.equal(user1Stake);
    expect(await await autoreflectiveStaking.balanceOf(namedAccounts.deployer)).to.be.equal(stakeAmount.sub(user1Stake));

    const deployersOldBalance = (await mockToken.balanceOf(namedAccounts.deployer)).sub(totalReward).sub(dust);
    const user1sOldBalance = await mockToken.balanceOf(namedAccounts.user1);

    for (let i = 0; i < daysInMonth; i++) {
      await autoreflectiveStaking.notifyRewardAmount(rewardAmount);
      await networkHelpers.time.increase(DAY);
      
      const randomChoice = Math.floor(Math.random() * 4);
      switch (randomChoice) {
        case 0: // deployer and user1 decided not to do anything
          console.log('deployer and user1 did nothing.');
          break;
        case 1: // deployer decided to withdraw and user1 decided to stay
          await autoreflectiveStaking.withdraw(deployerStake.div(daysInMonth));
          console.log(`deployer withdrawn ${hre.ethers.utils.formatEther(deployerStake.div(daysInMonth))}`);
          break;
        case 2: // deployer decided to stay and user1 decided to withdraw
          await autoreflectiveStaking.connect(user1Signer).withdraw(user1Stake.div(daysInMonth));
          console.log(`user 1 withdrawn ${hre.ethers.utils.formatEther(user1Stake.div(daysInMonth))}`);
          break;
        case 3: // deployer and user decided to withdraw
          await autoreflectiveStaking.withdraw(deployerStake.div(daysInMonth));
          await autoreflectiveStaking.connect(user1Signer).withdraw(user1Stake.div(daysInMonth));
          console.log(`deployer and user1 withdrawn: ${hre.ethers.utils.formatEther(deployerStake.div(daysInMonth))}, ${hre.ethers.utils.formatEther(user1Stake.div(daysInMonth))}`);
          break;
      }
    }

    const deployersWithdrawnTokens = await mockToken.balanceOf(namedAccounts.deployer);
    const user1sWithdrawnTokens = await mockToken.balanceOf(namedAccounts.user1);

    expect(deployersOldBalance).to.be.lte(deployersWithdrawnTokens, "Deployers balance after staking is less than it should be.");
    expect(user1sOldBalance).to.be.lte(user1sWithdrawnTokens, "User1s balance after staking is less than it should be.");
  });
});