const hre = require('hardhat');
const configurableWrappedStakingLocusStage = require('../stages/substages/reusables/configurableWrappedStakingLocusStage');
module.exports = configurableWrappedStakingLocusStage(
  () => hre.names.internal.diamonds.locusMockTokensStaking.proxy,
  () => hre.names.internal.mockLocus,
  true
);
module.exports.tags = ["mockWrappedStakingLocusStage", "mockStLOCUS"];
