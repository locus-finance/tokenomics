const { expect } = require("chai");
const networkHelpers = require("@nomicfoundation/hardhat-network-helpers");
const hre = require("hardhat");
const { deployments, getNamedAccounts } = hre;
const { WEEK, withImpersonatedSigner, mintNativeTokens } = require("../../../deploy/helpers");

describe("ASDepositaryFacet", () => {
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

});