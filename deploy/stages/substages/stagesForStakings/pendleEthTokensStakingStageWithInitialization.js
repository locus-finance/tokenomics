const hre = require('hardhat');
const configurableStakingStage = require('../reusables/configurableStakingStage');
module.exports = configurableStakingStage(
    "LocusPendleEthTokens", 
    true, 
    () => hre.names.external.pendleEth,
    () => hre.names.internal.diamonds.locusToken.proxy
);
module.exports.tags = ["pendleEthTokensStakingStageWithInitialization", "pendleEthStakingWithInit"];
