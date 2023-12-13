const networkHelpers = require("@nomicfoundation/hardhat-network-helpers");
const hre = require("hardhat");
const { deployments, getNamedAccounts } = hre;
const { WEEK, withImpersonatedSigner, mintNativeTokens } = require("../deploy/helpers");

describe("DiamondLocusStaking", () => {
  let namedAccounts;

  beforeEach(async () => {
    namedAccounts = await getNamedAccounts();
    await deployments.fixture([
      "configure",
      "tokenWithInit",
      "stakingWithInit",
      "claim",
      "tracer"
    ]);

  });

  it('should perform delayed withdrawal', async () => {

  });
});