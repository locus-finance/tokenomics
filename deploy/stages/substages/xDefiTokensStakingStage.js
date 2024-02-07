const hre = require('hardhat');
const configurableStakingStage = require('./reusables/configurableStakingStage');
module.exports = configurableStakingStage("LocusXDefiTokens", false, hre.names.external.xDEFI);
module.exports.tags = ["xDefiTokensStakingStage", "xDefiStaking"];
