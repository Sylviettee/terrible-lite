import Client, dotenv from require 'Comrade'
import readdirSync from require 'fs'

dotenv.config!

assert process.env.TOKEN, 'No token located in env!'

bot = Client process.env.TOKEN, {
  prefix: '>',
  logFile: './logs/discordia.log',
  gatewayFile: './logs/gateway.json'
}

bot\on 'ready', () ->
  bot\removeCommand 'help'

  for _, path in pairs readdirSync './commands'
    if path\endswith '.lua'
      bot\addCommand require "./commands/#{path\sub 0, #path - 4}"

bot\login {
  name: "terrible lite!"
}