const { expect } = require("chai");
const { deployments, getNamedAccounts } = hre;
const { StandardMerkleTree } = require("@openzeppelin/merkle-tree");
const { getMockTree } = require('../../deploy/helpers');

describe("MidasClaim", () => {
  let tokenMock;
  let mockStaking;
  let claim;
  let namedAccounts;

  beforeEach(async () => {
    namedAccounts = await getNamedAccounts();
    await deployments.fixture(['midasClaimFixtures']);
    claim = await hre.ethers.getContractAt(
      hre.names.internal.midasClaim,
      (await deployments.get(hre.names.internal.midasClaim)).address
    );
    tokenMock = await hre.ethers.getContractAt(
      hre.names.internal.mockLocus,
      (await deployments.get(hre.names.internal.mockLocus)).address
    );
    mockStaking = await hre.ethers.getContractAt(
      hre.names.internal.mockStaking,
      (await deployments.get(hre.names.internal.mockStaking)).address
    );
  });

  it("should deploy contract", async () => {
    expect(await tokenMock.balanceOf(claim.address)).to.be.gt(0);
    expect(await claim.token()).to.eq(tokenMock.address);
    expect(await claim.treasury()).to.eq(namedAccounts.treasury);
    expect(await claim.stLocus()).to.eq(mockStaking.address);
    expect(await claim.merkleRoot()).to.eq(
      getMockTree(namedAccounts.user1, namedAccounts.user2).root
    );
    expect(await claim.owner()).to.eq(namedAccounts.deployer);
  });

  it("should claim tokens", async () => {
    let sum = 0;
    const tree = getMockTree(namedAccounts.user1, namedAccounts.user2);
    for (const [i, v] of tree.entries()) {
      const proof = tree.getProof(i);
      await claim.claim(v[0], v[1], proof);
      sum = hre.ethers.BigNumber.from(sum).add(hre.ethers.BigNumber.from(v[1]));
      expect(await mockStaking.sent(v[0])).to.eq(v[1]);
      expect(await tokenMock.balanceOf(mockStaking.address)).to.eq(sum);
    }
  });

  it("should fail due to bad leaf", async () => {
    let badData = [
      ["0x6194738930D4239e596C1CC624Fb1cEa4ebE2665", "1000000000000000000"],
    ];
    let badTree = StandardMerkleTree.of(badData, ["address", "uint256"]);
    for (const [i, v] of badTree.entries()) {
      const proof = badTree.getProof(i);
      await expect(
        claim.claim(v[0], v[1], proof)
      ).to.be.revertedWithCustomError(claim, "ProofIsNotValid");
    }
  });

  it("should emergency exit", async () => {
    expect(await tokenMock.balanceOf(claim.address)).to.be.greaterThan(0);
    expect(await tokenMock.balanceOf(namedAccounts.treasury)).to.be.eq(0);
    await claim.emergencyExit();
    expect(await tokenMock.balanceOf(namedAccounts.treasury)).to.be.greaterThan(0);
    expect(await tokenMock.balanceOf(claim.address)).to.be.eq(0);
  });
});
