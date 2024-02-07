const hre = require('hardhat');
const configurableStakingStage = require('./reusables/configurableStakingStage');
module.exports = configurableStakingStage("LocusVaultTokens", false, hre.names.external.xDEFI);
module.exports.tags = ["xDefiTokensStakingStage", "xDefiStaking"];
