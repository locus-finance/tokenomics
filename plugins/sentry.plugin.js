const Sentry = require("@sentry/node");
module.exports = (hre) => {
  // LICENCE: MIT
  // Author: Oleg Bedrin <simplavero@gmail.com>
  // This is a plugin wrapper of Sentry around Hardhat Runtime Environment.
  Sentry.init({
    dsn: process.env.SENTRY_DSN,
    tracesSampleRate: 1.0,
  });
  const configuration = {
    op: process.env.SENTRY_OP,
    name: process.env.SENTRY_NAME
  };
  hre.sentry = {
    instance: Sentry,
    configuration,
    start: async (action) => {
      Sentry.startSpan(configuration, await action(Sentry));
    }
  };
};