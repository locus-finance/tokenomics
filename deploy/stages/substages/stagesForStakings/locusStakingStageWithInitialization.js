const hre = require('hardhat');
const configurableStakingStage = require('../reusables/configurableStakingStage');
module.exports = configurableStakingStage(
    "Locus", 
    true,
    undefined, 
    () => hre.names.internal.diamonds.locusToken.proxy
);
module.exports.tags = ["locusStakingStageWithInitialization", "stakingWithInit"];
