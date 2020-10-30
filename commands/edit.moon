import Command, Template, util from require 'Comrade'
import Engine, draw from require '../engine'

import request from require 'coro-http'
import encode, decode from require 'json'

Prompt = require '../prompt'

haste = 'https://hasteb.in/'

numbers = {
  "c#": 1
  "vb": 2
  "f#": 3
  "java": 4
  "c": 5
  "c++": 6
  "php": 8
  "pascal": 9
  "objective-c": 10
  "haskell": 11
  "ruby": 12
  "rerl": 13
  "lua": 14
  "nasm": 15
  "sql": 16
  "javascript": 17
  "lisp": 18
  "prolog": 19
  "go": 20
  "scala": 21
  "scheme": 22
  "node": 23
  "python": 24
  "d": 30
  "tcl": 32
  "oracle": 35
  "swift": 37
  "bash": 38
  "ada": 39
  "erlang": 40
  "elixir": 41
  "ocaml": 42
  "kotlin": 43
  "brainfuck": 44
  "fortran": 45
  "rust": 46
  "clojure": 47
}

eval = (code, lang) ->
  toSend = encode {
    LanguageChoice: tostring(numbers[lang]),
    Program: code,
    Input: "",
    CompilerArgs: ""
  }

  _, body = request 'POST', 'https://rextester.com/rundotnet/api', {
    {'content-type', 'application/json'},
    {'content-length', #toSend}
  }, toSend

  body = decode body

  body

expand = (engine) ->
  table.concat((engine.modules and engine.modules) or {}, "\n") .. "\n#{engine.text}"

class edit extends Command
  new: =>
    super!

    @description = 'Simple text editor which also can evaluate code'

    @longDescription = [[
Terrible lite is a terrible text editor which can evaluate code and write it.

- Commands list -

* edit - Edit the current line
* goto - Goto the specified line
* new - Create a line under current line
* count - Print out current lines
* down (d) - Go down a line
* up (u) - Go up a line
* lang - Change the language
* eval - Evaluate the currently written code
* exit - Close the editor
* locate - Locate the specified string
* clear - Clear the slate
* export - Export the code to hastebin
* import - Import code from hastebin

The editor has a 2 minute timeout!
]]

  execute: (msg, _, client) =>
    engine = Engine "--// Blank notepad \\\\--", {:draw}

    engine.language = "lua"

    Prompt msg, client, {
      timeout: util.minutes(2),
      -- useEdits: true,
      tasks: {
        {
          message: () ->
            content = "```#{engine.language}\n-------------------------\n--| Terrible lite v0.1 |--\n-------------------------\n#{engine\render!}\n```"

            if #content > 2000
              content = "#{content\sub 0, 1900}\n```\n-- #{#content - 1900} characters unable to be displayed --"

            content

          action: (content, prompt) ->
            args = content\split ' '

            cmd = args[1]

            args = table.slice args, 2

            if cmd == 'edit'
              engine\editLine table.concat args, ' '

            elseif cmd == 'goto'
              line = tonumber args[1]

              unless line
                prompt\reply 'Invalid number!'
              
              if line > #engine.text\split '\n'
                prompt\reply "Out of range [1 - #{#engine.text\split '\n'}]!"

              engine.pos = line
  
            elseif cmd == 'new'
              if tonumber args[1]
                for i = 1, tonumber args[1]
                  engine\newLine!
                prompt\reply "Created #{tonumber args[1]} new lines!"
              else
                engine\newLine!

            elseif cmd == 'count'
              prompt\reply "There are #{#engine.text\split '\n'} lines."

            elseif cmd == 'down' or cmd == 'd'
              engine\down!

            elseif cmd == 'up' or cmd == 'u'
              engine\up!

            elseif cmd == 'eval'
              prompt\reply 'Please wait while evaluating...'

              res = eval expand(engine), engine.language

              prompt\reply "```#{engine.language}\n#{res.Stats}\n-- Stdout --\n#{res.Result}\n-- Stderr --\n#{res.Errors or 'nil'}\n```"

            elseif cmd == "lang"
              return prompt\reply 'No language specified!' unless args[1]

              if numbers[args[1]\lower!]
                engine.language = args[1]\lower!
              else
                prompt\reply 'That language is not supported!'

            elseif cmd == "locate"
              query = table.concat args, ' '

              lines = {}

              for num, line in pairs engine.text\split '\n'
                if line\match query
                  table.insert lines, num

              prompt\reply "```lua\n-- Location results --\n#{table.concat lines, ',\n'}\n```"

            elseif cmd == "clear"
              engine.pos = 1
              engine.text = "--// Blank notepad \\\\--"
            
            elseif cmd == "mod"
              -- Embed the data within the engine
              -- When exporting / evaluating they are expanded

              engine.modules and table.insert engine.modules, engine.text

              unless engine.modules
                engine.modules = {engine.text}

              prompt\reply "Saved module!"
            
            elseif cmd == "mods"
              prompt\reply "You have #{engine.modules and #engine.modules or 0} modules enabled"

            elseif cmd == "export"
              prompt\reply "Exporting..."

              _, res = request 'POST', "#{haste}documents", {
                {'Content-Type', 'text/plain'}
                {'Content-Length', #expand engine}
              }, expand engine
        
              body = decode res
        
              {:key} = body
        
              msg\reply "Exported to hastebin: #{haste}#{key}.#{engine.language}"

            elseif cmd == "import"
              key = args[1]\match "https?://hasteb%.in/(%w+)%..*"

              return msg\reply 'Invalid hastebin url!' unless key

              prompt\reply "Importing..."

              headers, res = request 'GET', "#{haste}raw/#{key}"

              if headers.code != 200
                return prompt\reply "Unable to fetch data!"

              engine.text = res

            elseif cmd == 'exit'
              prompt\reply 'Exiting editor!'
              return prompt\close!

            prompt\redo!
        }
      }
    }

edit!