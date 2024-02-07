const { emptyStage } = require('../helpers');
module.exports = emptyStage('Debug stage performed.');
module.exports.tags = ["upgrade"];
module.exports.dependencies = [
  "configure",
  "token",
  "staking",
  "xDefiStaking",
  "claim",
  "stLOCUS",
  "tracer"
];
module.exports.runAtTheEnd = true;
