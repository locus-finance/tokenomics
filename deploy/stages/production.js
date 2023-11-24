const { emptyStage } = require('../helpers');
module.exports = emptyStage('Production stage performed.');
module.exports.tags = ["production"];
module.exports.dependencies = [
  "staking",
  "update_tracer_names"
];
module.exports.runAtTheEnd = true;
