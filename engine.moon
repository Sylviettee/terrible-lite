-- Rendering engine for terminal text editor

split = (str, delim = '%s') ->
  ret = {}
  return ret unless str

  if not delim or delim == ''
    for c in string.gmatch str, '.'
      table.insert ret, c

    return ret
  
  n = 1

  while true
    i, j = string.find str, delim, n
    break unless i

    table.insert ret, string.sub str, n, i - 1
    n = j + 1
  
  table.insert ret, string.sub str, n

  ret

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
    @lines = split text, '\n'

    @draw = (txt) => 
      if conf.draw
        return conf.draw @, txt
      
      print '\27[2J'
      print txt

    @pos = 1
    @text = ""

  line: =>
    -- Line text
    --  p @lines
    new = ''

    for i, v in pairs @lines
      new = "#{new}#{i}#{rep ' ', (#tostring #@lines) - #tostring i} |#{i == @pos and '>' or ' '} #{v}\n"

    new

  render: =>
    @text = table.concat(@lines, '\n')\trim!

    @draw @line @text

  down: =>
    @pos = clamp @pos + 1, 1, (#@lines) + 1
    @render!

  up: =>
    @pos = clamp @pos - 1, 1, (#@lines) + 1
    @render!

  editLine: (new) =>
    @lines[@pos] = new

    @render!
  
  newLine: =>
    if @lines[@pos]
      @lines[@pos] ..= '\n'

      -- Reformat the lines
      @lines = split table.concat(@lines, '\n'), '\n'
    else
      @lines[@pos] = ''

    @render!

draw = (text) =>

  splitted = @lines

  starting = clamp @pos - 5, 1, #splitted

  linesToRender = table.slice splitted, starting, clamp @pos + 5, 1, #splitted

  new = {}

  for i = 0, #linesToRender - 1
    v = linesToRender[i + 1]

    maxNum = #splitted
    currentNum = i + starting
    spaces = getSpaces maxNum, currentNum

    table.insert new, "| #{currentNum}#{rep ' ', spaces} |#{currentNum == @pos and '>' or ' '} #{v}"

  "| #{rep '=', getSpaces(#splitted, @pos) + #tostring(@pos)} |
| #{@pos}#{rep ' ', getSpaces(#splitted, @pos) + 1}|
| #{rep '=', getSpaces(#splitted, @pos) + #tostring(@pos)} |
#{table.concat new, '\n'}"

print_draw = (...) ->
  print '\27[2J'
  print draw ...

{
  :Engine,
  :draw,
  :print_draw
}

