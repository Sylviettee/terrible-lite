import Command from require 'Comrade'

class help extends Command
  new: =>
    super!

    @description = 'view all the commands or get information on commands'
    @example = {
      'help help',
      'help all'
    }
    @usage = '<command name>'

  all: (msg, args, client) =>
    desc = '```\nCommands\n'

    client.commands\forEach (command) ->
      desc = "#{desc}\t#{command.name}\n"

    msg\reply "#{desc}\n```"
  
  execute: (msg, args, client) =>
    unless args[1]
      @all msg, args, client
    else
      command = client.commands\find (com) ->
        com.name == args[1] or table.search com.aliases, args[1]

      if command
        unless command.formatted
          formatted = ''

          command.example = {command.example} if type(command.example) == 'string'

          for _,v in pairs command.example
            formatted ..= "\t#{v}\n"

          command.formatted = formatted

        sub = "\t#{command.name} #{command.usage == command.name and '' or command.usage}\n"

        for name in pairs command.subcommands
          sub = "#{sub}\t#{command.name} #{name}\n"

        msg\reply "
```
NAME
\t#{command.name} - #{command.description}

SYNOPSIS
#{sub}

DESCRIPTION
\t#{command.longDescription and table.concat(command.longDescription\split('\n'), '\n\t') or command.description}

EXAMPLES
#{command.formatted}
```
"
      else
        msg\reply "No help entry for #{args[1]}"

help!