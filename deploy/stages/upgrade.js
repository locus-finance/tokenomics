const { emptyStage } = require('../helpers');
module.exports = emptyStage('Upgrade stage performed.');
module.exports.tags = ["upgrade"];
module.exports.dependencies = [
  "configure",
  "token",
  "staking",
  "xDefiStaking",
  "xArbStaking",
  "xEthStaking",
  "xUsdStaking",
  "claim",
  "stLOCUS",
  "tracer"
];
module.exports.runAtTheEnd = true;
