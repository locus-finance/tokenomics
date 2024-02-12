const configurableWrappedStakingLocusStage = require('./reusables/configurableWrappedStakingLocusStage');
module.exports = configurableWrappedStakingLocusStage(
  () => hre.names.internal.diamonds.locusStaking.proxy,
  () => hre.names.internal.diamonds.locusToken.proxy,
);
module.exports.tags = ["wrappedStakingLocusStage", "stLOCUS"];
