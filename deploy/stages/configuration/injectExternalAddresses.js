const hre = require('hardhat');
const { getFakeDeployment } = require('../../helpers');

module.exports = async ({
  getNamedAccounts,
  deployments,
  network
}) => {
  const { log, save } = deployments;

  // Injecting Midas Token
  await getFakeDeployment(
    "0x97e6e31afb2d93d437301e006d9da714616766a5",
    hre.names.external.midas,
    save
  );

  // Injecting Presale Gnosis Safe
  await getFakeDeployment(
    "0x1A07EaaF78ceffd17f15d06373A1E3A75dAF9d85",
    hre.names.external.presale,
    save
  );

  // Injecting All Fees Receiver EOA
  await getFakeDeployment(
    "0x56bf05C28eF161fC6fc2C2DaC037d70eF97af6D1",
    hre.names.external.allFeesReceiver,
    save
  );
  
  log(`External addresses are injected:\n${JSON.stringify(hre.names.external)}`);
}
module.exports.tags = ["injectExternalAddresses"], "configure";
