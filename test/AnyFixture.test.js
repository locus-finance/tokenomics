const hre = require("hardhat");
const { deployments } = hre;
describe("AnyFixture", () => {
  it("Successful fixture performance", async () => {
    // await deployments.fixture(['debug']);
    const claim = await hre.ethers.getContractAt(
      hre.names.internal.midasClaim,
      "0x445816ac3E78D1B0547b4642b373A88aD875cc8a"
    );
    const locus = await hre.ethers.getContractAt(
      hre.names.internal.diamonds.locusToken.interface,
      "0xe1d3495717f9534db67a6a8d4940dd17435b6a9e"
    );
    console.log((await locus.balanceOf(claim.address)).toString());
    await claim.claim(
      "0x301f9D47CC5072Cd5653fDb01669a5216Ff67A75",
      "529959380000000000000",
      []
    );
  });
});