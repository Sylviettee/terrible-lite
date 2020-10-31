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

Editor.addCommand = (name, fn) =>
  assert type(name) == "string", "A command must have a name as a string"
  assert type(fn) == "function", "A command must have a callback fn as a function"

  @_commands[name] = fn

  if #@_commands > 15
    -- Assume command spam to steal memory
    coroutine.yield 'Max commands is 15'

Editor.reject = (name) =>
  error name -- Command state should handle the error

Editor.editCurrentLine = (text) =>
  assert text, 'A text argument is required'
  if text\match 'lua is bad'
    coroutine.yield 'Invalid opinion'

  @_engine\editLine text -- Spamming doesn't cause re-render

(engine, prompt, code) ->
  co = coroutine.create () ->
    editor = Editor engine, prompt

    protect(code, {
      env: {
        editor: {
          addCommand: (...) =>
            editor\addCommand ...
          reject: (...) =>
            editor\reject ...
          editCurrentLine: (...) =>
            editor\editCurrentLine ...
        }
        edit: (text) ->
          editor\editCurrentLine text
      }
      quota: 10000
    })!

    coroutine.yield editor

  succ, editor = coroutine.resume co

  unless succ
    prompt\reply "Unable to fully load config: #{editor}"
    return nil

  if type(editor) == 'string'
    prompt\reply "Sandbox killed for: #{editor}, setting to default config!"
    return nil

  editor[3], (fn, args) -> -- Reuse sandbox
    p args
    pcall () ->
      newFn = () -> fn args
      protect(newFn, {
        env: {
          editor: {
            addCommand: (...) =>
              editor\addCommand ...
            reject: (...) =>
              editor\reject ...
            editCurrentLine: (...) =>
              editor\editCurrentLine ...
          }
          edit: (text) ->
            editor\editCurrentLine text
          :args
        }
        quota: 10000
      })!

