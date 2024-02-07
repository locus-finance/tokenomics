const { emptyStage } = require('../helpers');
module.exports = emptyStage('Debug stage performed.');
module.exports.tags = ["deploy"];
module.exports.dependencies = [
  "configure",
  "tokenWithInit",
  "stakingWithInit",
  "xDefiStakingWithInit",
  "claim",
  "stLOCUS",
  "tracer"
];
module.exports.runAtTheEnd = true;
