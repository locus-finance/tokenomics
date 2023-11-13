const { emptyStage } = require('../helpers');
module.exports = emptyStage('General fixture...');
module.exports.tags = ["general_test_fixtures"];
module.exports.dependencies = [
    "main",
    "updateTracerNames"
];
module.exports.runAtTheEnd = true;
