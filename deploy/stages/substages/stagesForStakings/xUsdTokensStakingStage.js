const hre = require('hardhat');
const configurableStakingStage = require('../reusables/configurableStakingStage');
module.exports = configurableStakingStage(
    "LocusXUsdTokens", 
    false, 
    () => hre.names.external.xUSD,
    () => hre.names.internal.diamonds.locusToken.proxy
);
module.exports.tags = ["xUsdTokensStakingStage", "xUsdStaking"];
