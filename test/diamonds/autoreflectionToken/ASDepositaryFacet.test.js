const { expect } = require("chai");
const hre = require("hardhat");
const { deployments, getNamedAccounts } = hre;
const { WEEK, withImpersonatedSigner, mintNativeTokens } = require("../../../deploy/helpers");

describe("ASDepositaryFacet", () => {
  let namedAccounts;
  let user1Balance;

  let autoreflectiveStaking;
  let mockToken;

  beforeEach(async () => {
    namedAccounts = await getNamedAccounts();
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
    console.log(`pre transfer u1: ${(await autoreflectiveStaking.balanceOf(namedAccounts.user1)).toString()}`);
    console.log(`pre transfer d: ${(await autoreflectiveStaking.balanceOf(namedAccounts.deployer)).toString()}`);
    await autoreflectiveStaking.transfer(namedAccounts.user1, user1Balance);
    console.log(`post transfer u1: ${(await autoreflectiveStaking.balanceOf(namedAccounts.user1)).toString()}`);
    console.log(`post transfer d: ${(await autoreflectiveStaking.balanceOf(namedAccounts.deployer)).toString()}`);
  });

});