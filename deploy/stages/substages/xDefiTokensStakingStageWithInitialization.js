const hre = require('hardhat');
const configurableStakingStage = require('./reusables/configurableStakingStage');
module.exports = configurableStakingStage("LocusVaultTokens", true, hre.names.external.xDEFI);
module.exports.tags = ["xDefiTokensStakingStageWithInitialization", "xDefiStakingWithInit"];
