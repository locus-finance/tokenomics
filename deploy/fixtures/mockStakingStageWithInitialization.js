const hre = require('hardhat');
const configurableStakingStage = require('../stages/substages/reusables/configurableStakingStage');
module.exports = configurableStakingStage(
    "LocusMockTokens", 
    true, 
    () => hre.names.internal.mockLocus,
    () => hre.names.internal.mockLocus
);
module.exports.tags = ["mockStakingStageWithInitialization", "mockStakingWithInit"];
