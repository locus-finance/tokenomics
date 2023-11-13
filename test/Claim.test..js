const { expect } = require("chai");
const {
  reset,
  loadFixture,
} = require("@nomicfoundation/hardhat-network-helpers");
const { ethers } = require("hardhat");
const { StandardMerkleTree } = require("@openzeppelin/merkle-tree");
const { BigNumber } = require("ethers");

const ETH_NODE = process.env.ETH_NODE;
const ETHEREUM_FORK_BLOCK = process.env.ETHEREUM_FORK_BLOCK;

let balances = [
  ["", "10000000000000000000000000"],
  ["", "20000000000000000000000000"],
];

function generateMerkleTree() {
  return StandardMerkleTree.of(balances, ["address", "uint256"]);
}

async function deployContractAndSetVariables() {
  await reset(ETH_NODE, Number(ETHEREUM_FORK_BLOCK));
  const [deployer, user1, user2, treasury] = await ethers.getSigners();
  const TokenMock = await ethers.getContractFactory("MockLocus");
  const tokenMock = await TokenMock.deploy(deployer.address);
  await tokenMock.deployed();

  const MockStaking = await ethers.getContractFactory("MockStaking");
  const mockStaking = await MockStaking.deploy(tokenMock.address);
  await mockStaking.deployed();

  balances[0][0] = user1.address;
  balances[1][0] = user2.address;
  const tree = generateMerkleTree();

  const Claim = await ethers.getContractFactory("Claim");
  const claim = await Claim.deploy(
    tokenMock.address,
    mockStaking.address,
    tree.root,
    treasury.address
  );
  await claim.deployed();

  await tokenMock.mint(claim.address, ethers.utils.parseEther("1000000000"));

  return {
    tokenMock,
    mockStaking,
    claim,
    tree,
    deployer,
    user1,
    user2,
    treasury,
  };
}

describe("Claim", () => {
  let fixtureData;

  beforeEach(async () => {
    fixtureData = await loadFixture(deployContractAndSetVariables);
  });

  it("should deploy contract", async () => {
    const { claim, tokenMock } = fixtureData;
    expect(await tokenMock.balanceOf(claim.address)).to.be.gt(0);
    expect(await claim.token()).to.eq(tokenMock.address);
    expect(await claim.treasury()).to.eq(treasury.address);
    expect(await claim.stLocus()).to.eq(mockStaking.address);
    expect(await claim.merkleRoot()).to.eq(tree.root);
    expect(await claim.owner()).to.eq(deployer.address);
  });

  it("should claim tokens", async () => {
    let sum = 0;
    for (const [i, v] of tree.entries()) {
      const proof = tree.getProof(i);
      await claim.claim(v[0], v[1], proof);
      sum = BigNumber.from(sum).add(BigNumber.from(v[1]));
      expect(await mockStaking.sended(v[0])).to.eq(v[1]);
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
      ).to.be.revertedWithCustomError(claim, "Claim__ProofIsNotValid");
    }
  });

  it("should emergency exit", async () => {
    expect(await tokenMock.balanceOf(claim.address)).to.be.greaterThan(0);
    expect(await tokenMock.balanceOf(treasury.address)).to.be.eq(0);
    await claim.emergencyExit();
    expect(await tokenMock.balanceOf(treasury.address)).to.be.greaterThan(0);
    expect(await tokenMock.balanceOf(claim.address)).to.be.eq(0);
  });
});
