const hre = require('hardhat');
const configurableStakingStage = require('../reusables/configurableStakingStage');
module.exports = configurableStakingStage("LocusXArbTokens", false, hre.names.external.xARB);
module.exports.tags = ["xArbTokensStakingStage", "xArbStaking"];
