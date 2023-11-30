const networkHelpers = require("@nomicfoundation/hardhat-network-helpers");
const hre = require("hardhat");
const { deployments, getNamedAccounts } = hre;
const { WEEK, withImpersonatedSigner, mintNativeTokens } = require("../deploy/helpers");

// TO BE UTILIZED ONLY FOR HYPOTHESIS' TESTING!!!
describe("AnyFixture", () => {
  xit('should work', async () => {
    const locusStaking = await hre.ethers.getContractAt(
      hre.names.internal.diamonds.locusStaking.interface,
      "0xEcc5e0c19806Cf47531F307140e8b042D5Afb952"
    );
    const locusToken = await hre.ethers.getContractAt(
      hre.names.internal.diamonds.locusToken.interface,
      "0xe1d3495717f9534Db67A6A8d4940Dd17435b6A9E"
    );
    const person = "0x35AC85c14Be0acc68870348F33B150364aF35303";
    const personBalance = await locusToken.balanceOf(person);
    console.log(personBalance.toString());
    console.log((await locusStaking.balanceOf(person)).toString());
    console.log((await locusStaking.getCurrentFeeBps(person)).toString());
    console.log('---');
    await withImpersonatedSigner(person, async (personSigner) => {
      await mintNativeTokens(personSigner, "0x1000000000000000000000");
      await locusToken.connect(personSigner).approve(locusStaking.address, personBalance);
      await locusStaking.connect(personSigner).stake(personBalance);
      await locusStaking.connect(personSigner).withdraw(personBalance);
    });
    console.log((await locusToken.balanceOf(person)).toString());
    console.log((await locusStaking.balanceOf(person)).toString());
  });

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

    console.log('offchain');
    console.log((await locusToken.balanceOf(deployer)).toString());
    console.log((await locusStaking.balanceOf(deployer)).toString());
    console.log('---');
    await locusStaking.withdraw(amount);
    console.log('***');
    console.log((await locusToken.balanceOf(deployer)).toString());
    
    // await networkHelpers.time.increase(WEEK + 1);
    // console.log((await locusStaking.getCurrentFeeBps(deployer)).toString());
    // await networkHelpers.time.increase(WEEK * 2);
    // console.log((await locusStaking.getCurrentFeeBps(deployer)).toString());
    // await networkHelpers.time.increase(WEEK);
    // console.log((await locusStaking.getCurrentFeeBps(deployer)).toString());
  });
});