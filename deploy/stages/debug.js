const { emptyStage } = require('../helpers');
module.exports = emptyStage('Debug stage performed.');
module.exports.tags = ["debug"];
module.exports.dependencies = [
  "claim",
  "token",
  "staking",
  "governance",
  "update_tracer_names"
];
module.exports.runAtTheEnd = true;
