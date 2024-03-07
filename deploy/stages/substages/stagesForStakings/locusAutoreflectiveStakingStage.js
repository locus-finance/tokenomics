const hre = require('hardhat');
const configurableAutoreflectiveStakingStage = require('../reusables/configurableAutoreflectiveStakingStage');
module.exports = configurableAutoreflectiveStakingStage(
  false,
  () => hre.names.internal.diamonds.locusToken.proxy
);
module.exports.tags = ["locusAutoreflectiveStakingStage", "autoreflection"];
