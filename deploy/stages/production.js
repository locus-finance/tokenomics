const { emptyStage } = require('../helpers');
module.exports = emptyStage('Production stage performed.');
module.exports.tags = ["production"];
module.exports.dependencies = [
  "configure",
  "token",
  "staking",
  "claim",
  "tracer"
];
module.exports.runAtTheEnd = true;
