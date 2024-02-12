const hre = require('hardhat');
const configurableStakingStage = require('../reusables/configurableStakingStage');
module.exports = configurableStakingStage(
    "LocusXEthTokens", 
    false, 
    () => hre.names.external.xETH,
    () => hre.names.internal.diamonds.locusToken.proxy
);
module.exports.tags = ["xEthTokensStakingStage", "xEthStaking"];
