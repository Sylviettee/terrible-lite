-- Things involving the configuration/utilities of the editor

{
  mods: (engine, _, _, prompt) ->
    prompt\reply "You have #{engine.modules and #engine.modules or 0} modules enabled"

  mod: (engine, _, _, prompt) ->
    engine.modules and table.insert engine.modules, engine.text

    unless engine.modules
      engine.modules = {engine.text}

    prompt\reply "Saved module!"

  clear: (engine, _, _, prompt) ->
    engine.pos = 1
    engine.text = "--// Blank notepad \\\\--"

    return prompt\redo!

  locate: (engine, _, args, prompt) ->
    query = table.concat args, ' '

    lines = {}

    for num, line in pairs engine.text\split '\n'
      if line\match query
        table.insert lines, num

    prompt\reply "```lua\n-- Location results --\n#{table.concat lines, ',\n'}\n```"

  exit: (_, _, args, prompt) ->
    prompt\reply 'Exiting editor!'

    if args[1] == "clean"
      toClean = {}

      for _,v in pairs prompt.sent
        table.insert toClean, v.id

      prompt.channel\bulkDelete toClean

    return prompt\close!

  count: (engine, _, _, prompt) ->
    prompt\reply "There are #{#engine.text\split '\n'} lines."

  new: (engine, _, args, prompt) ->
    if tonumber args[1]
      for i = 1, tonumber args[1]
        engine\newLine!
      prompt\reply "Created #{tonumber args[1]} new lines!"
    else
      engine\newLine!
    return prompt\redo!

  edit: (engine, content, _, prompt) ->
    engine\editLine content\sub 6, #content
    return prompt\redo!

  refresh: (engine, _, _, prompt) ->
    prompt.message = prompt\reply "```#{engine.language}
-------------------------
--| Terrible lite v0.1 |--
-------------------------

-- Powered by: http://github.com/comrade-project/comrade --

#{engine\render!}
```"

  help: (_, _, _, prompt, cmd) ->
    prompt\reply "```md\n#{cmd.longDescription}\n```"
}