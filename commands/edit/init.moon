import Command, Template, util from require 'Comrade'
import Engine, draw from require '../../engine'
import conn, get from require '../../database'

Prompt = require '../../prompt'

box = require './editorApi'

merge = (tbl, toMerge) ->
  for _, v in pairs toMerge
    for i, k in pairs v
      tbl[i] = k

  tbl

cmds = merge {}, {
  require './http'
  require './movement'
  require './util'
  require './config'
}

class edit extends Command
  new: =>
    super!

    @description = 'Simple text editor which also can evaluate code'

    @longDescription = [[
Terrible lite is a terrible text editor which can evaluate code and write it.

# Commands list

## Movement
* down (d) [count] - Move down on the prompt
* up (u) [count] - Move up on the prompt

## Config
* view - View the currently used config
* save - Save current workspace into config

## Http
* export - Export the code to hastebin
* import - Import code from hastebin
* eval - Evaluate using rextester api
* lang - Change language to evaluate

## Util

* exit [clean] - Exit the prompt
* clear - Clear all the lines
* locate <query> - Search for specific text
* count - Count the amount of lines
* new [count] - Create a new line below current
* edit <content> - Edit the current line
* mods - Return count of loaded modules
* mod - Save current code as module
* help - This message
* refresh - Post a new message with editor

# Notes -

* The editor has a 2 minute timeout!
* Im an idiot
]]

  execute: (msg, args, client) =>
    engine = Engine "--// Blank notepad \\\\--", {:draw}

    engine.language = "lua"

    usrConfig = get 'users', 'UserId', msg.author.id
    
    unless usrConfig
      conn\exec "INSERT INTO users (UserId) VALUES (\"#{msg.author.id}\")"
      usrConfig = get 'users', 'UserId', msg.author.id

    config = usrConfig[3]

    useEdits = true

    if args[1] == "no-edits"
      useEdits = false

    Prompt msg, client, {
      timeout: util.minutes(2),
      :useEdits,
      tasks: {
        {
          message: 'now'
          action: (_, prompt) ->
            -- Setup sandbox
            engine.conf = config

            custom, runner = box engine, prompt, config

            prompt\save 'custom', custom
            prompt\save 'runner', runner

            prompt\next!
        }
        {
          message: () ->
            content = "```#{engine.language}
-------------------------
--| Terrible lite v0.1 |--
-------------------------

-- Powered by: http://github.com/comrade-project/comrade --

#{engine\render!}
```"

            if #content > 2000
              content = "#{content\sub 0, 1900}\n```\n-- #{#content - 1900} characters unable to be displayed --"

            content

          action: (content, prompt) ->
            args = content\split ' '

            cmd = args[1]

            args = table.slice args, 2

            custom = prompt\get 'custom'
            run = prompt\get 'runner'

            if custom[cmd\lower!]
              succ, err = run custom[cmd\lower!], args
              unless succ
                prompt\reply "Failed to run custom command: #{err}"
              return prompt\redo!

            if cmds[cmd\lower!]
              cmds[cmd\lower!](engine, content, args, prompt, @)
            else
              prompt\reply 'Unknown command!'
        }
      }
    }

edit!