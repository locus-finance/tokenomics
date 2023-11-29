const { emptyStage } = require('../helpers');
module.exports = emptyStage('Debug stage performed.');
module.exports.tags = ["debug"];
module.exports.dependencies = [
  "configure",
  "token",
  "staking",
  "claim",
  "tracer"
];
module.exports.runAtTheEnd = true;
