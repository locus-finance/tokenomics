const { types } = require("hardhat/config");
module.exports = (task) =>
  task(
    "discord",
    "Sends a discord message through hre.discord plugin.",
  )
    .addOptionalParam('message', "Define a message to send to the discord errors channel.", "Test-O, hackersssss!", types.string)
    .setAction(async ({ message }, hre) => {
        await hre.discord.sendDiscordMessage(message);
        console.log('Sent successfully!');
    });
