const hre = require("hardhat");
const { deployments } = hre;
describe("AnyFixture", () => {
  it("Successful fixture performance", async () => {
    await deployments.fixture(['debug']);
  });
});