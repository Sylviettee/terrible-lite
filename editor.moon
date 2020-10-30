import Engine, print_draw from require './engine'

engine = Engine "-- Welcome to chaos --", { draw: print_draw }

print engine\render!

-- Handles testing

{:stdin, :stdout} = require 'pretty-print'

local menuCb
inMenu = false
contents = ''
prompt = ''

stdin\set_mode 1

stdin\read_start (err, key) ->
  -- p string.byte key
  if err
    return process\exit 1

  if key == '\003'
    process\exit!
  elseif key == '\r' and inMenu
    inMenu = false
    return menuCb!
  elseif string.byte(key) == 127 and inMenu
    contents = contents\sub 0, #contents - 1
    return stdout\write "\27[3g\27[2K#{prompt}#{contents}"

  if inMenu
    contents = "#{contents}#{key}"
    return stdout\write key
  
  if key == '\027[B'
    engine\down!
  elseif key == '\027[A'
    engine\up!
  elseif key == 'e'
    inMenu = true
    contents = ''
    prompt = 'line > '

    menuCb = () ->
      engine\editLine contents

    stdout\write 'line > '
  elseif key == 'g'
    inMenu = true
    contents = ''
    prompt = 'goto > '

    menuCb = () ->
      contents = tonumber contents

      unless contents
        engine\render!
        return stdout\write 'Invalid number!\n'

      if contents > #split engine.text, '\n'
        engine\render!
        return stdout\write 'Line out of range!\n'

      engine.pos = contents
      engine\render!
    
    stdout\write 'goto > '
  elseif key == '\r'
    engine\newLine!


--stdin\on 'keypress', (str) ->
--  p str