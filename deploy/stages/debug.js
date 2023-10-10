const { emptyStage } = require('../helpers');
module.exports = emptyStage('Debug stage performed.');
module.exports.tags = ["debug"];
module.exports.dependencies = [
  "main",
  "update_tracer_names"
];
module.exports.runAtTheEnd = true;
