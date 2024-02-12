const hre = require('hardhat');
const configurableStakingStage = require('../reusables/configurableStakingStage');
module.exports = configurableStakingStage(
    "LocusXArbTokens", 
    false, 
    () => hre.names.external.xARB,
    () => hre.names.internal.diamonds.locusToken.proxy
);
module.exports.tags = ["xArbTokensStakingStage", "xArbStaking"];
