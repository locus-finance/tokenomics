const { expect } = require("chai");
const networkHelpers = require("@nomicfoundation/hardhat-network-helpers");
const hre = require("hardhat");
const keccak256 = require('keccak256');
const { deployments, getNamedAccounts } = hre;
const { WEEK, withImpersonatedSigner, mintNativeTokens } = require("../../../deploy/helpers");

describe("ASDepositaryFacet", () => {
  let namedAccounts;
  let user1Balance;
  let totalReward;

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
    
  });

});