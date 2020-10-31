import dotenv from require 'Comrade'
import readdirSync, lstatSync from require 'fs'

dotenv.config!

assert process.env.TOKEN, 'No token located in env!'

require './database'

Client = require './client'

bot = Client process.env.TOKEN, {
  prefix: 'sd;',
  logFile: './logs/discordia.log',
  gatewayFile: './logs/gateway.json'
}

for _, path in pairs readdirSync './commands'
  if path\endswith '.lua'
    bot\addCommand require "./commands/#{path\sub 0, #path - 4}"
  elseif lstatSync("./commands/#{path}").type == 'directory'
    bot\addCommand require "./commands/#{path}"

bot\login {
  name: "#{bot.prefix}edit | Chaotic Lite"
}