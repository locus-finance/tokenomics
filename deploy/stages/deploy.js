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
  "pendleEthStakingWithInit",
  "claim",
  "tracer"
];
module.exports.runAtTheEnd = true;
