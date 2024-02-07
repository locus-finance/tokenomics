const hre = require('hardhat');
const { getFakeDeployment } = require('../helpers');

module.exports = async ({
  getNamedAccounts,
  deployments,
  network
}) => {
  const { log, save } = deployments;
  // Initiate indexing of all artifacts names.
  await hre.names.gather();

  // Injecting xDEFI Vault
  await getFakeDeployment(
    "0xB0a66dD3B92293E5DC946B47922C6Ca9De464649",
    hre.names.external.xDEFI,
    save
  );

  // Injecting xETH Vault
  await getFakeDeployment(
    "0x0CD5cda0E120F7E22516f074284e5416949882C2",
    hre.names.external.xETH,
    save
  );

  // Injecting xARB Vault
  await getFakeDeployment(
    "0xF8F045583580C4Ba954CD911a8b161FafD89A9EF",
    hre.names.external.xARB,
    save
  );

  // Injecting xUSD Vault
  await getFakeDeployment(
    "0x2a889E9ef10c7Bd607473Aadc8c806c4511EB26f",
    hre.names.external.xARB,
    save
  );

  // Injecting All Fees Receiver EOA
  await getFakeDeployment(
    "0x56bf05C28eF161fC6fc2C2DaC037d70eF97af6D1",
    hre.names.external.allFeesReceiver,
    save
  );
  
  log(`external addresses are injected`);
}
module.exports.tags = ["globalConfiguration", "configure"];
