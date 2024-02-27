const hre = require('hardhat');
const configurableAutoreflectiveStakingStage = require('../reusables/configurableAutoreflectiveStakingStage');
module.exports = configurableAutoreflectiveStakingStage(
  hre.ethers.utils.parseEther('32500'),
  false,
  () => hre.names.internal.diamonds.locusToken.proxy,
  () => hre.names.internal.diamonds.locusToken.proxy
);
module.exports.tags = ["locusAutoreflectiveStakingStage", "autoreflection"];
