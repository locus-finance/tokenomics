const { lazyObject, HardhatPluginError } = require("hardhat/plugins");

module.exports = (hre) => {
  // LICENCE: MIT
  // Author: Oleg Bedrin <simplavero@gmail.com>
  // This is a template plugin for future synchronization of diamonds facets info with the DB.
  
  if (hre.names === undefined || !hre.names.isInitialized) {
    throw new HardhatPluginError(
      "disync", 
      "The plugin `names` MUST be plugged in and initialized so the `disync` could be dependant on that.");
  }

  hre.disync = {};

  hre.disync.migrate = async () => {};
  hre.disync.clean = async () => {};
  hre.disync.crud = async () => {};
};