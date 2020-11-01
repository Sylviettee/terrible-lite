--- Public editor api
-- @module editor

import protect from require './sandbox'

_class = require('discordia').class -- Public/private class implementation
-- Sandbox disallows rawget, rawget, getmetatable and other things which allows you to go around
-- the restriction

Editor = _class 'Editor'

Editor.__init = (engine, prompt) =>
  @_engine = engine
  @_prompt = prompt

  @_commands = {}

--- Register a command, there is a max of 15 commands!
-- @tparam string name The name of the command
-- @tparam function fn The function to run the command
Editor.addCommand = (name, fn) =>
  assert type(name) == "string", "A command must have a name as a string"
  assert type(fn) == "function", "A command must have a callback fn as a function"

  @_commands[name] = fn

  if #@_commands > 15
    -- Assume command spam to steal memory
    coroutine.yield 'Max commands is 15'

--- Alias for error
-- @tparam string msg The message to send
Editor.reject = (msg) =>
  error msg -- Command state should handle the error

--- Edit the current line of the editor
-- @tparam string text What to replace the line with
Editor.editCurrentLine = (text) =>
  assert text, 'A text argument is required'
  if text\match 'lua is bad'
    coroutine.yield 'Invalid opinion'

  @_engine\editLine text -- Spamming doesn't cause re-render

--- Change the position of the cursor
-- @tparam number pos The position to move the cursor
Editor.editCursorPosition = (pos) =>
  assert type(pos) == 'number', 'The position must be a number!'
  assert pos > 1, 'The position must be greater then 1!'
  assert pos <= #@_engine.text\split('\n'), 'The position must be less then the total lines!'

  @_engine.pos = pos

--- Get the text from the editor
-- @treturn number text
Editor.getText = =>
  @_engine.text

--- Get the current cursor position
-- @treturn number position
Editor.getCursorPosition = =>
  @_engine.pos

getEnv = (editor) ->
  {
    addCommand: (_, ...) -> editor\addCommand ...
    reject: (_, ...) -> editor\reject ...
    editCurrentLine: (_, ...) -> editor\editCurrentLine ...
    getText: (_, ...) -> editor\getText ...
    getCursorPosition: (_, ...) -> editor\getCursorPosition ...
  }

(engine, prompt, code) ->
  co = coroutine.create () ->
    editor = Editor engine, prompt

    protect(code, {
      env: {
        editor: getEnv editor
        edit: (text) ->
          editor\editCurrentLine text
      }
    })!

    coroutine.yield editor

  succ, editor = coroutine.resume co

  unless succ
    prompt\reply "Unable to fully load config: #{editor}"\sub 0, 2000
    return nil

  if type(editor) == 'string'
    prompt\reply "Sandbox killed for: #{editor}, setting to default config!"\sub 0, 2000
    return nil

  editor[3], (fn, args) -> -- Reuse sandbox
    pcall () ->
      newFn = () -> fn args
      protect(newFn, {
        env: {
          editor: getEnv editor
          edit: (text) ->
            editor\editCurrentLine text
          :args
        }
      })!

