import conn from require '../../database'

expand = (engine) ->
  table.concat((engine.modules and engine.modules) or {}, "\n") .. "\n#{engine.text}"

{
  view: (engine, _, _, prompt) ->
    prompt\reply "```lua
#{engine.conf}
```"
  save: (engine, _, _, prompt) ->
    return prompt\reply "Configs must be in Lua!" unless engine.language == "lua"

    stmt = conn\prepare "UPDATE users SET Config = ? WHERE UserId = #{prompt.id}"

    stmt\reset!\bind(expand engine)\step!

    prompt\reply "Saved config, reload editor to see changes!"
}