-- Modified client

import version, Array from require 'Comrade'

discordia = require 'discordia'

import enums from discordia

Class,Client = discordia.class,discordia.Client

helper,get = Class 'Modified Client', Client

options = {
  'routeDelay'
  'maxRetries'
  'shardCount'
  'firstShard'
  'lastShard'
  'largeThreshold'
  'cacheAllMembers'
  'autoReconnect'
  'compress'
  'bitrate'
  'logFile'
  'logLevel'
  'gatewayFile'
  'dateTime'
  'syncGuilds'
}

helper.__init = (token,config={}) =>
  clientConfig = {}

  for i,v in pairs config
    if table.search options, i
      clientConfig[i] = v

  Client.__init(@, clientConfig)

  assert token, 'A token is required!'
  @_token = token
  @_prefix = config.prefix or '!'

  @_prefix = type(@_prefix) == 'string' and {@_prefix} or @_prefix

  @_disableDefaultCH = config.disableDefaultCH or false
  @_owners = config.owners or {}

  @_testing = config.testing or config.testbot or false
  @_testbot = config.testbot or false
  @_botid = config.botid or nil

  @_errors = (@_testing or config.storeErrors) and {}
  @_ready = false

  if @_botid
    table.insert @_owners, @_botid -- Testing bot should be owner

  @_start = os.time!

  @_commands = Array!
  @_events = Array!
  @_plugins = Array!

  @_events = Array!

  @\on 'ready', () ->
    @_ready = true
    @\info "Ready as #{@user.tag}"
    
    if @_testing
      @addCommand require './status'

  unless @_testbot or @_disableDefaultCH
    @\on 'messageCreate', (msg) ->
      local prefix

      for _, pre in pairs @_prefix
        if string.match msg.content, "^#{pre}"
          prefix = pre
          break
      
      return nil unless prefix

      if msg.author.bot and msg.author.id != @_botid
        return nil 

      perms = (msg.guild and msg.guild.me\getPermissions msg.channel) or {has: () -> true}
      
      return @\debug "Comrade : No send messages" unless perms\has enums.permission.sendMessages -- If we can't send messages then just reject

      command = string.match msg.content, "#{prefix}(%S+)"

      return nil unless command

      args = {}

      for arg in string.gmatch string.match(msg.content, "#{prefix}%S+%s*(.*)"), '%S+'
        table.insert args, arg

      command = command\lower!

      found = @_commands\find (val) ->
        val\check command,msg, @

      if found
        @\debug "Comrade : Ran #{command}"

        succ,err = pcall () -> 
          found\run msg,args, @

        unless succ
          @\debug "Comrade : Error #{err}"
          @\error err

helper.login = (status) =>
  @run "Bot #{@_token}"
  if status
    @setGame status

helper.info = (...) =>
  unless @_testing
    @_logger\log 3, ...

  @\emit 'info', string.format ...

helper.error = (...) =>
  unless @_testing
    @_logger\log 1, ...

  @\emit 'error', string.format ...
  
  if @_errors
    table.insert @_errors, string.format ...

helper.resetErrors = =>
  @_errors = {}

helper.updateOwners = (owners) =>
  @_owners = owners

helper.addCommand = (command) =>
  @\debug "Comrade: New command #{command.name}"
  @_commands\push command

helper.removeCommand = (name, check = () -> false) =>
  @_commands\forEach (command, pos) ->
    if command.name == name or check command, name
      @_commands\pop pos

helper.addEvent = (event) =>
  @\debug "Comrade: New listener #{event.name}"
  event\use @
  @_events\push event

helper.removeEvent = (name, check = () -> false) =>
  @_events\forEach (event, pos) ->
    if event.name == name or check event, name
      @_events\pop pos
      @\removeListener event.__class.__name, event.execute

helper.removePlugin = (name) =>
  @removeCommand '', (com) ->
    com.parent == name
  @removeEvent '', (event) ->
    event.parent == name

get.start = =>
  @_start
get.commands = =>
  @_commands
get.version = ->
  version
get.owners = =>
  @_owners
get.ready = =>
  @_ready
get.prefix = =>
  @_prefix[1]
get.prefixes = =>
  @_prefix
get.errors = =>
  @_errors

helper