const hre = require('hardhat');
const configurableStakingStage = require('../reusables/configurableStakingStage');
module.exports = configurableStakingStage("LocusXArbTokens", true, hre.names.external.xARB);
module.exports.tags = ["xArbTokensStakingStageWithInitialization", "xArbStakingWithInit"];
