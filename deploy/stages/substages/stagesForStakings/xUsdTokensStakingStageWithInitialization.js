const hre = require('hardhat');
const configurableStakingStage = require('../reusables/configurableStakingStage');
module.exports = configurableStakingStage(
    "LocusXUsdTokens", 
    true, 
    () => hre.names.external.xUSD,
    () => hre.names.internal.diamonds.locusToken.proxy
);
module.exports.tags = ["xUsdTokensStakingStageWithInitialization", "xUsdStakingWithInit"];
