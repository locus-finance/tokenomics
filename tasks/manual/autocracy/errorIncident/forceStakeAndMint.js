const { types } = require("hardhat/config");
const fsExtra = require("fs-extra");

module.exports = (task) =>
  task(
    "forceStakeAndMint",
    "Force stake an amount for a user, and mints specified amount of LOCUS\' to them.",
  )
    .addOptionalParam("latest", "An address of the autoreflective staking.", '', types.string)
    .addOptionalParam("locus", "Define a name or address of LOCUS token contract in hre.names.", '', types.string)
    .addOptionalParam("user", "An address of the lucky one.", '', types.string)
    .addOptionalParam("confirmations", "An amount of confirmations to wait each iteration of incident liquidation.", 10, types.int)
    .addOptionalParam("stake", "An amount to force stake for user.", '', types.string)
    .addOptionalParam("mint", "An amount to force stake for user.", '0', types.string)
    .setAction(async ({ locus, confirmations, user, stake, mint, latest }, hre) => {
      await hre.names.gather();
      const locusAddress = locus !== '' ? locus : (await hre.deployments.get(hre.names.internal.diamonds.locusToken.proxy)).address
      const locusInstance = await hre.ethers.getContractAt(
        hre.names.internal.diamonds.locusToken.interface,
        locusAddress
      );
      const newStakingAddress = latest === '' ? (await hre.deployments.get(hre.names.internal.diamonds.autoreflectiveStaking.proxy)).address : latest;

      const stakeBigNumber = hre.ethers.utils.parseEther(stake);
      const mintBigNumber = hre.ethers.utils.parseEther(mint);

      if (mintBigNumber.gt(0)) {
        const mintTx = await locusInstance.mint(user, mintBigNumber);
        await mintTx.wait(confirmations);
        console.log(`Minted ${mint} LOCUS\' for user ${user}.`);
      } else {
        console.log('Nothing to mint.');
      }
      console.log(`Initiating force staking for user ${user}.`);

      if (stakeBigNumber.gt(0)) {
        const forceStakeForTx = await locusInstance.forceStakeFor(
          user,
          stakeBigNumber,
          newStakingAddress
        );
        await forceStakeForTx.wait(confirmations);
        console.log(`Force staked of ${stake} LOCUS\' has been made for user ${user}.\nTx info:\n${JSON.stringify(forceStakeForTx)}`);
      } else {
        console.log('Nothing to force stake for the user.');
      }
    });
