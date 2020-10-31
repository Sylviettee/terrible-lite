----
-- A prompt helper class
-- @classmod prompt

import embed from require 'Comrade'

prompts = {}

globalActions = {
  check: (content,prompt) ->
    if content == 'n' or content == 'no'
      prompt\reply 'Closing prompt, open again to correct'
      prompt\close!
    elseif content == 'y' or content == 'yes'
      prompt\next!
    else
      prompt\redo! 
}

class
  @__name = 'Prompt'
  --- Construct a prompt to get user information
  -- @param msg The message
  -- @param client A Discordia or Comrade client
  -- @tparam config config A config containing the tasks, timeout, and if its an embed 
  new: (msg,client,config) =>
    return msg\reply 'Finish the currently open prompt' if prompts[msg.author.id]

    prompts[msg.author.id] = true

    @id = msg.author.id

    @stage = 0
    @data = {}
    @sent = {}

    @message = nil

    @channel = msg.channel
    @client = client

    @tasks = config.tasks
    @timeout = config.timeout or 30000

    @embed = config.embed or false

    @useEdits = config.useEdits or false

    @closed = false

    @co = coroutine.create () ->
      loop = ->
        called, msg = client\waitFor 'messageCreate', @timeout, (recieved) ->
          recieved.author.id == msg.author.id and recieved.channel.id == msg.channel.id and not @closed
        unless called
          @channel\send 'Closing prompt!' unless @closed
          @close! unless @closed
        else
          @handle msg
          loop!
      loop!

    @next!

    coroutine.resume @co

  -- Progression

  --- Move on the prompt
  next: =>
    @stage += 1
    @update!

  --- Go back on the prompt
  back: =>
    @stage -= 1
    @update!

  --- Redo the current prompt task
  redo: =>
    @update!

  --- Close the prompt
  close: =>
    @closed = true

    prompts[@id] = false

  --- Send a message in the prompt channel
  reply: (content) =>
    msg = @channel\send content

    table.insert @sent, msg

    msg
  
  --- Save a value into the prompt
  save: (key,value) =>
    @data[key] = value

  --- Get a value from the prompt
  get: (key) =>
    @data[key]

  --- Internal; Handle the action
  handle: (msg = {}) =>
    if globalActions[@tasks[@stage].action]
      globalActions[@tasks[@stage].action] msg.content, @, msg
    else
      @tasks[@stage].action msg.content or nil, @, msg

  -- Sending

  --- Internal; Handle the message
  update: =>
    message = @tasks[@stage].message

    if type(message) == 'function'
      message = message!

    if message == 'now'
      return @handle!

    unless @message
      return @channel\send 'Error: No tasks found' unless @tasks[@stage]
      if @embed
        @message = message\send @channel
      else 
        @message = @channel\send message
      table.insert @sent, @message
    else
      return @channel\send 'Error: Prompt out of tasks' unless @tasks[@stage]

      if message ~= 'none'
        if @embed 
          unless message.render
            table.insert @sent, message\send @channel
          else
            local get

            unless message.usingEtLua
              get = (text, render) ->
                render @get text
            else
              get = (text) ->
                @get text
            
            rendered = message\render({
              :get
              step: @step
              timeout: @timeout
            })

            table.insert @sent, rendered\send @channel
        else
          if @useEdits
            @message\setContent message
          else
            table.insert @sent, @message\reply message