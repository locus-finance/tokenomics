const hre = require('hardhat');
const configurableStakingStage = require('../reusables/configurableStakingStage');
module.exports = configurableStakingStage(
    "LocusXEthTokens", 
    true, 
    () => hre.names.external.xETH,
    () => hre.names.internal.diamonds.locusToken.proxy
);
module.exports.tags = ["xEthTokensStakingStageWithInitialization", "xEthStakingWithInit"];
