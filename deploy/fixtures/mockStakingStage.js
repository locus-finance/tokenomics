const hre = require('hardhat');
const configurableStakingStage = require('../stages/substages/reusables/configurableStakingStage');
module.exports = configurableStakingStage("LocusMockTokens", false, () => hre.names.internal.mockLocus);
module.exports.tags = ["mockStakingStage", "mockStaking"];
