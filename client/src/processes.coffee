
# Processes

Communicator =
  commandStack: []
  
  init: ->
    url = "ws://#{window.location.hostname}:8080/"
    @ws = new WebSocket(url)
    that = this
    
    @ws.onopen = ->
      console.log("WebSocket opened")
    @ws.onmessage = (e) ->
      commands = JSON.parse(e.data)
      for command in commands
        that.commandStack.push(command)
    @ws.onclose = (e) ->
      console.log("WebSocket closed")
    @ws.onerror = (e) ->
      console.log("WebSocket error", e)
  
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
  
  playerMove: (position) ->
    data = {
      cmd: 'playerMove',
      position: position.toArray()
    }
    @ws.send(JSON.stringify(data))


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
    @ctx = @canvas.getContext('2d')
    @ctx.mozImageSmoothingEnabled = false
    @ctx.webkitImageSmoothingEnabled = false
  
  render: ->
    # Clear screen
    @ctx.clearRect(0, 0, @canvas.width, @canvas.height)
    
    @ctx.save()
    zoom = 3
    @ctx.scale(zoom, zoom)
    
    # Set up camera crew
    offset = if Game.player
      Game.player.location.position.sub(new Vector(7, 4))
    else
      new Vector()
    
    # Filter and sort entities
    entities = []
    for id, entity of Entity.all
      entities.push(entity) if entity.location and entity.sprite
    entities.sort (a, b) ->
      a.location.layer - b.location.layer
    
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
      position.x = 14 if position.x > 14
      position.y = 9 if position.y > 9
      
      Game.player.location.position = position
      Communicator.playerMove(position)
