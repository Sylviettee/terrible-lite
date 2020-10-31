-- Functions that involve saending http requests

import request from require 'coro-http'
import encode, decode from require 'json'

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

{
  eval: (engine, _, args, prompt) ->
    prompt\reply 'Please wait while evaluating...'

    res = eval expand(engine), engine.language

    prompt\reply "```#{engine.language}\n#{res.Stats}\n-- Stdout --\n#{res.Result}\n-- Stderr --\n#{res.Errors or 'nil'}\n```"

  export: (engine, _, _, prompt) ->
    prompt\reply "Exporting..."

    _, res = request 'POST', "#{haste}documents", {
      {'Content-Type', 'text/plain'}
      {'Content-Length', #expand engine}
    }, expand engine

    body = decode res

    {:key} = body

    prompt\reply "Exported to hastebin: #{haste}#{key}.#{engine.language}"

  import: (engine, _, args, prompt) ->
    key = args[1]\match "https?://hasteb%.in/(%w+)%..*"

    return prompt\reply 'Invalid hastebin url!' unless key

    prompt\reply "Importing..."

    headers, res = request 'GET', "#{haste}raw/#{key}"

    if headers.code != 200
      return prompt\reply "Unable to fetch data!"

    engine.text = res
    return prompt\redo!

  lang: (engine, _, args, prompt) ->
    return prompt\reply 'No language specified!' unless args[1]

    if numbers[args[1]\lower!]
      engine.language = args[1]\lower!
    else
      prompt\reply 'That language is not supported!'

    return prompt\redo!
}