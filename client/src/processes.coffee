
# Processes

Communicator =
  log: false
  commandStack: []
  requestStack: []
  
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
  
  # Commands
  processCommands: ->
    while args = @commandStack.shift()
      command = args.cmd
      delete args.cmd
      @commands[command](args)
  
  commands:
    entityCreate: (args) ->
      Game.entities[args.id] = args.entity
    entityUpdate: (args) ->
      entity = Game.entities[args.id]
      Utils.merge(entity, args.entity, true)
    entityDelete: (args) ->
      delete Game.entities[args.id]
    playerSet: (args) ->
      Game.player = Game.entities[args.id]
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


# Maintains a constant controller state
Controller =
  init: ->
    @keys = {}
    that = @
    
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
    
    that = @
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
    center = if Game.player
      position = Vector.fromArray(Game.player.location.position)
      position.add(new Vector(0.5, 0.5))
    else
      new Vector()
    viewportSize = new Vector(@canvas.width, @canvas.height).div(16 * Game.settings.zoom)
    viewport = new Rect(center.sub(viewportSize.div(2)), viewportSize)
    
    # Filter and sort entities
    entities = []
    for id, entity of Game.entities
      entities.push(entity) if entity.location
    entities.sort (a, b) ->
      (a.location.layer - b.location.layer) or
        a.location.position[1] - b.location.position[1]
    
    # Draw entities
    for id, entity of entities
      position = Vector.fromArray(entity.location.position)
      box = new Rect(position, new Vector(1, 1))
      # Only draw the entity if it will display on the screen
      if viewport.overlaps(box)
        sprite = Game.sprites[entity.sprite]
        sprite.drawTo(@ctx, box.position.sub(viewport.position))
    
    @ctx.restore()


Movement =
  move: ->
    delta = new Vector(0, 0)
    delta.addto(new Vector(1, 0)) if Controller.isPressed(39)
    delta.addto(new Vector(0, 1)) if Controller.isPressed(40)
    delta.addto(new Vector(-1, 0)) if Controller.isPressed(37)
    delta.addto(new Vector(0, -1)) if Controller.isPressed(38)
    
    if delta.norm() > 0 and Game.player
      delta = delta.normalize().mul(Game.settings.speed / 16)
      position = Vector.fromArray(Game.player.location.position).add(delta)
      
      # Really dumb collision handling
      position.x = 0 if position.x < 0
      position.y = 0 if position.y < 0
      
      Game.player.location.position = position.toArray()
      Communicator.playerMove(position)
