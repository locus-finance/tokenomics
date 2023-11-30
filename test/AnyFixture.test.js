const networkHelpers = require("@nomicfoundation/hardhat-network-helpers");
const hre = require("hardhat");
const { deployments, getNamedAccounts } = hre;
const { WEEK } = require("../deploy/helpers");

// TO BE UTILIZED ONLY FOR HYPOTHESIS TESTING!!!
describe("AnyFixture", () => {
  it("Successful fixture performance", async () => {
    await deployments.fixture(['debug']);
    const { deployer } = await getNamedAccounts();
    const locusStaking = await hre.ethers.getContractAt(
      hre.names.internal.diamonds.locusStaking.interface,
      (await deployments.get(hre.names.internal.diamonds.locusStaking.proxy)).address
    );
    const locusToken = await hre.ethers.getContractAt(
      hre.names.internal.diamonds.locusToken.interface,
      (await deployments.get(hre.names.internal.diamonds.locusToken.proxy)).address
    );
    const amount = hre.ethers.utils.parseEther('10');
    await locusToken.mint(deployer, amount);
    await locusToken.approve(locusStaking.address, amount);
    await locusStaking.stake(amount);

    console.log((await locusStaking.getCurrentFeeBps()).toString());
    await networkHelpers.time.increase(WEEK + 1);
    console.log((await locusStaking.getCurrentFeeBps()).toString());
    await networkHelpers.time.increase(WEEK * 2);
    console.log((await locusStaking.getCurrentFeeBps()).toString());
    await networkHelpers.time.increase(WEEK);
    console.log((await locusStaking.getCurrentFeeBps()).toString());
  });
});