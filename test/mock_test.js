const hre = require("hardhat");
const {
  withImpersonatedSigner,
  mintNativeTokens,
  DEAD_ADDRESS,
  getEventBody
} = require('../deploy/helpers');
const { expect } = require('chai');
const { deployments, getNamedAccounts } = hre;
const { get } = deployments;
const { time } = require('@nomicfoundation/hardhat-network-helpers');

describe("Contract", () => {
  let deployer;

  beforeEach(async () => {
    await deployments.fixture(['debug']);
    const accounts = await getNamedAccounts();
    deployer = accounts.deployer;
  });

  it("Successful before each", async () => {});
});