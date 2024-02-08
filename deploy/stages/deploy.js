const { emptyStage } = require('../helpers');
module.exports = emptyStage('Deploy stage performed.');
module.exports.tags = ["deploy"];
module.exports.dependencies = [
  "configure",
  "tokenWithInit",
  "stakingWithInit",
  "xDefiStakingWithInit",
  "xArbStakingWithInit",
  "xEthStakingWithInit",
  "xUsdStakingWithInit",
  "claim",
  "stLOCUS",
  "tracer"
];
module.exports.runAtTheEnd = true;
