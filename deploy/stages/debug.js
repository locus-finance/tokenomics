const { emptyStage } = require('../helpers');
module.exports = emptyStage('Debug stage performed.');
module.exports.tags = ["debug"];
module.exports.dependencies = [
  "configure",
  "tokenWithInit",
  "stakingWithInit",
  "claim",
  "tracer"
];
module.exports.runAtTheEnd = true;
