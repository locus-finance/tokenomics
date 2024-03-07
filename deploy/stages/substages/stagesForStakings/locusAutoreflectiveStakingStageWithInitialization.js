const hre = require('hardhat');
const configurableAutoreflectiveStakingStage = require('../reusables/configurableAutoreflectiveStakingStage');
module.exports = configurableAutoreflectiveStakingStage(
  true,
  () => hre.names.internal.diamonds.locusToken.proxy
);
module.exports.tags = ["locusAutoreflectiveStakingStageWithInitialization", "autoreflectionWithInit"];
