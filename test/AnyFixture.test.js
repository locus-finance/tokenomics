const hre = require("hardhat");
const { deployments, getNamedAccounts } = hre;
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
    await locusToken.stake(amount);
    console.log((await locusStaking.getCurrentFeeBps()).toString());
  });
});