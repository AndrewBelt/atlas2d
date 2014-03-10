
# Processes

Communicator =
  log: false
  commandStack: []
  requestStack: []
  
  init: ->
    url = "ws://#{window.location.hostname}:8080/"
    @ws = new WebSocket(url)
    that = this
    
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
  
  # Commands
  processCommands: ->
    while args = @commandStack.shift()
      command = args.cmd
      delete args.cmd
      @commands[command](args)
  
  commands:
    entityCreate: (args) ->
      entity = new Entity()
      entity.deserialize(args.entity)
      Entity.all[args.id] = entity
    entityUpdate: (args) ->
      entity = Entity.all[args.id]
      entity.deserialize(args.entity)
    entityDelete: (args) ->
      delete Entity.all[args.id]
    playerSet: (args) ->
      Game.player = Entity.all[args.id]
      console.log("Set player to \##{args.id}")
  
  # Requests
  pushRequests: ->
    if @ws.readyState == 1 and @requestStack.length > 0
      json = JSON.stringify(@requestStack)
      @ws.send(json)
      console.log("Sent #{json.length} bytes") if @log
      @requestStack.length = 0
  
  playerMove: (position) ->
    @requestStack.push {
      cmd: 'playerMove',
      position: position.toArray()
    }


# Maintains a constant keyboard state
Keyboard =
  init: ->
    @keys = {}
    that = this
    
    window.onkeydown = (e) ->
      that.keys[e.keyCode] = true
    window.onkeyup = (e) ->
      delete that.keys[e.keyCode]
    window.onblur = ->
      that.keys = {}
  
  isPressed: (key) ->
    @keys[key]?


Renderer =
  init: ->
    @canvas = document.getElementById('main')
    
    that = this
    window.onload = window.onresize = ->
      that.resize(document.body.clientWidth, document.body.clientHeight)
  
  resize: (width, height) ->
    @canvas.width = width
    @canvas.height = height
    # We have to reset the context settings
    @ctx = @canvas.getContext('2d')
    @ctx.mozImageSmoothingEnabled = false
    @ctx.webkitImageSmoothingEnabled = false
  
  render: ->
    return unless @ctx
    # Clear screen
    @ctx.clearRect(0, 0, @canvas.width, @canvas.height)
    
    @ctx.save()
    @ctx.scale(Game.settings.zoom, Game.settings.zoom)
    
    # Set up camera crew
    viewSize = new Vector(@canvas.width, @canvas.height).div(16 * Game.settings.zoom)
    offset = if Game.player
      Game.player.location.position.sub(viewSize.div(2))
    else
      new Vector()
    
    # Filter and sort entities
    entities = []
    for id, entity of Entity.all
      entities.push(entity) if entity.location and entity.sprite
    entities.sort (a, b) ->
      ret = a.location.layer - b.location.layer
      return ret if ret
      a.location.position.y - b.location.position.y
    
    # Draw entities
    for id, entity of entities
      position = entity.location.position.sub(offset)
      entity.sprite.drawTo(@ctx, position)
    
    @ctx.restore()


Movement =
  move: ->
    offset = new Vector(0, 0)
    offset.addto(new Vector(1, 0)) if Keyboard.isPressed(39)
    offset.addto(new Vector(0, 1)) if Keyboard.isPressed(40)
    offset.addto(new Vector(-1, 0)) if Keyboard.isPressed(37)
    offset.addto(new Vector(0, -1)) if Keyboard.isPressed(38)
    
    if offset.norm() > 0 and Game.player
      offset = offset.normalize().mul(Game.settings.speed / 16)
      position = Game.player.location.position.add(offset)
      
      # Really dumb collision handling
      position.x = 0 if position.x < 0
      position.y = 0 if position.y < 0
      
      Game.player.location.position = position
      Communicator.playerMove(position)
