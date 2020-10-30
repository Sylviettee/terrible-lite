-- Rendering engine for terminal text editor

split = (str, sep = '%s') ->
    t = {}
  
    for part in string.gmatch str, "([^#{sep}]+)"
      table.insert t, part
    t

rep = (str, count) ->
  newStr = ''

  for i = 1, count
    newStr = "#{newStr}#{str}"

  newStr

clamp = (x, min, max) ->
  (x >= max and max) or (x <= min and min) or x

getSpaces = (max, current) ->
  #tostring(max) - (#tostring(max) - (#tostring(max) - #tostring(current)))

class Engine
  new: (text, conf = {}) =>
    @text = text

    @draw = (txt) => 
      if conf.draw
        return conf.draw @, txt
      
      print '\27[2J'
      print txt
    
    @pos = 1

  line: =>
    -- Line text
    splitted = split @text, '\n'

    new = ''

    for i, v in pairs splitted
      new = "#{new}#{i}#{rep ' ', (#tostring #splitted) - #tostring i} |#{i == @pos and '>' or ' '} #{v}\n"
    
    new

  render: =>
    @draw @line @text

  down: =>
    @pos = clamp @pos + 1, 1, (#split @text, '\n') + 1
    @render!

  up: =>
    @pos = clamp @pos - 1, 1, (#split @text, '\n') + 1
    @render!

  editLine: (new) =>
    splitted = split @text, '\n'

    splitted[@pos] = new

    @text = table.concat splitted, '\n'

    @render!
  
  newLine: =>
    splitted = split @text, '\n'

    if splitted[@pos]
      splitted[@pos] ..= "\n\r"
    else
      splitted[@pos] = "\n\r"

    @text = table.concat splitted, '\n'

    @render!

draw = (text) =>
  linesToRender = {}

  splitted = split @text, '\n'

  starting = clamp @pos - 5, 0, #splitted

  for i = starting, clamp @pos + 5, 0, #splitted + 1
    table.insert linesToRender, splitted[i]
  
  new = ''

  for i, v in pairs linesToRender
    maxNum = #splitted
    currentNum = i + starting
    spaces = getSpaces maxNum, currentNum

    new = "#{new}| #{currentNum}#{rep ' ', spaces} |#{currentNum == @pos and '>' or ' '} #{v}#{i != #linesToRender and '\n' or ''}"

  "| #{rep '=', getSpaces(#splitted, @pos) + #tostring(@pos)} |\n| #{@pos}#{rep ' ', getSpaces(#splitted, @pos) + 1}|\n| #{rep '=', getSpaces(#splitted, @pos) + #tostring(@pos)} |\n#{new}"

print_draw = (...) ->
  print '\27[2J'
  print draw ...

{
  :Engine,
  :draw,
  :print_draw
}

