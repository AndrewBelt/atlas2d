
Network =
  log: false
  commandStack: []
  
  init: ->
    url = "ws://#{window.location.hostname}:8080/"
    @ws = new WebSocket(url)
    that = @
    
    @ws.onopen = ->
      GUI.pushMessage("Connected to server", 'info')
    @ws.onmessage = (e) ->
      console.log("Recv #{e.data.length} bytes") if that.log
      commands = JSON.parse(e.data)
      for command in commands
        that.commandStack.push(command)
    @ws.onclose = (e) ->
      GUI.pushMessage("Disconnected from server", 'info')
    @ws.onerror = (e) ->
      GUI.pushMessage("Connection error", 'error')
  
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
      GUI.pushMessage(args.text, 'chat')


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
  playerFace: (direction) ->
    @push {
      cmd: 'playerFace',
      direction: direction
    }
  playerAnimate: (enabled) ->
    @push {
      cmd: 'playerAnimate',
      enabled: enabled
    }
  playerAction: () ->
    @push {
      cmd: 'playerAction'
    }
  chatSend: (text) ->
    @push {
      cmd: 'chatSend',
      text: text
    }