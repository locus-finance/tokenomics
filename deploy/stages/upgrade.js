const { emptyStage } = require('../helpers');
module.exports = emptyStage('Debug stage performed.');
module.exports.tags = ["upgrade"];
module.exports.dependencies = [
  "configure",
  "token",
  "staking",
  "claim",
  "stLOCUS",
  "tracer"
];
module.exports.runAtTheEnd = true;
