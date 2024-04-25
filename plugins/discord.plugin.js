const { lazyObject, HardhatPluginError } = require("hardhat/plugins");
const axios = require("axios");

module.exports = (hre) => {
  // LICENCE: MIT
  // Author: Oleg Bedrin <simplavero@gmail.com>
  // This is a plugin wrapper of Discord API around Hardhat Runtime Environment.
  const hookUrl = process.env.DISCORD_ERROR_WEBHOOK_URL;
  const userIdToTagInDiscordChannel = process.env.USER_ID_TO_TAG_IN_DISCORD;
  const axiosInstance = axios.create({
    baseURL: hookUrl,
    timeout: 100000
  });
  hre.discord = {
    hookUrl,
    sendDiscordMessage: async (message) => {
      const prefix = "TOKENOMICS ERROR MESSAGE: ";
      const response = await axiosInstance.request({
        method: "post",
        data: {
          content: `${prefix}${message}\n<@${userIdToTagInDiscordChannel}>`
        }
      });
      if (response.status !== 204) {
        throw Error(`Failed to send message to Discord. Status code: ${response.status}`);
      }
    }
  }
};