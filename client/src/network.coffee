
Network =
  log: false
  commandStack: []
  
  init: ->
    url = "ws://#{window.location.hostname}:8080/"
    @ws = new WebSocket(url)
    that = @
    
    @ws.onopen = ->
      console.log("WebSocket opened")
    @ws.onmessage = (e) ->
      console.log("Recv #{e.data.length} bytes") if that.log
      commands = JSON.parse(e.data)
      for command in commands
        that.commandStack.push(command)
    @ws.onclose = (e) ->
      console.log("WebSocket closed")
    @ws.onerror = (e) ->
      console.log("WebSocket error", e)
  
  pushRequests: ->
    return unless @ws.readyState == 1
    if Request.requestStack.length > 0
      json = JSON.stringify(Request.requestStack)
      @ws.send(json)
      console.log("Sent #{json.length} bytes") if @log
      Request.requestStack.length = 0
  
  processCommands: ->
    while args = @commandStack.shift()
      command = @commands[args.cmd]
      throw "'#{args.cmd}' is not a command" unless command
      delete args.cmd
      command(args)
  
  ## Commands (server --> client)
  commands:
    entityCreate: (args) ->
      Game.entities[args.id] = args.entity
    entityUpdate: (args) ->
      Utils.merge(Game.entities[args.id], args.entity, true)
    entityDelete: (args) ->
      delete Game.entities[args.id]
    playerSet: (args) ->
      Game.playerId = args.id
    chatDisplay: (args) ->
      GUI.chatDisplay(args.text)


Request =
  requestStack: []
  push: (command) ->
    @requestStack.push(command)
  
  ## Requests (client --> server)
  playerMove: (position) ->
    @push {
      cmd: 'playerMove',
      position: position.toArray()
    }
  chatSend: (text) ->
    @push {
      cmd: 'chatSend',
      text: text
    }
  action: () ->
    @push {
      cmd: 'action'
    }
