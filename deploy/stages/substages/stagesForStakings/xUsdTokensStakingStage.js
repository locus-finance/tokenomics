const hre = require('hardhat');
const configurableStakingStage = require('../reusables/configurableStakingStage');
module.exports = configurableStakingStage("LocusXUsdTokens", false, hre.names.external.xUSD);
module.exports.tags = ["xUsdTokensStakingStage", "xUsdStaking"];
