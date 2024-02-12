const hre = require('hardhat');
const configurableStakingStage = require('../reusables/configurableStakingStage');
module.exports = configurableStakingStage(
    "LocusXDefiTokens", 
    false, 
    () => hre.names.external.xDEFI,
    () => hre.names.internal.diamonds.locusToken.proxy
);
module.exports.tags = ["xDefiTokensStakingStage", "xDefiStaking"];
