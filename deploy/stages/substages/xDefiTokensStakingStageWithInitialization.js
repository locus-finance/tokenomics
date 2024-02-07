const hre = require('hardhat');
const configurableStakingStage = require('./reusables/configurableStakingStage');
module.exports = configurableStakingStage("LocusXDefiTokens", true, hre.names.external.xDEFI);
module.exports.tags = ["xDefiTokensStakingStageWithInitialization", "xDefiStakingWithInit"];
