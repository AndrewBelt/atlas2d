
# Processes

Communicator =
  commandStack: []
  
  init: ->
    url = "ws://#{window.location.hostname}:8080/"
    @ws = new WebSocket(url)
    that = this
    
    @ws.onopen = ->
      console.log("Websocket opened")
    @ws.onmessage = (e) ->
      commands = JSON.parse(e.data)
      for command in commands
        that.commandStack.push(command)
    @ws.onclose = (e) ->
      console.log("Websocket closed")
    @ws.onerror = (e) ->
      console.log("Websocket error", e)
  
  processCommands: ->
    while args = @commandStack.shift()
      command = args.command
      delete args.command
      @commands[command](args)
  
  commands:
    entityCreate: (args) ->
      entity = new Entity()
      entity.deserialize(args.entity)
      Entity.all[args.id] = entity
      # TEMP
      if args.id == 1
        Renderer.focus = entity
    entityUpdate: (args) ->
      entity = Entity.all[args.id]
      entity.deserialize(args.entity)
  
  movePlayer: (delta) ->
    data = {
      command: 'movePlayer',
      delta: delta.toArray()
    }
    @ws.send(JSON.stringify(data))


Controller =
  init: ->
    window.onkeydown = (e) ->
      # TEMP
      # Quick hack to set the screen offset for now
      # (Don't actually send to the Movement process)
      delta = switch e.keyCode
        when 37 then new Vector(-1, 0)
        when 38 then new Vector(0, -1)
        when 39 then new Vector(1, 0)
        when 40 then new Vector(0, 1)
      if delta
        Communicator.movePlayer(delta)
    window.onkeyup = (e) ->


Renderer =
  # The entity to be followed by the viewport
  focus: null
  
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
    offset = if @focus?
      @focus.location.position.sub(new Vector(7, 4))
    else
      new Vector()
    
    # Sort entities
    entities = []
    for id, entity of Entity.all
      entities.push(entity) if entity.location? and entity.sprite?
    entities.sort (a, b) ->
      a.location.layer - b.location.layer
    
    # Draw entities
    for id, entity of entities
      if entity.sprite? and entity.location?
        entity.sprite.drawTo(@ctx, entity.location.position.sub(offset))
    
    @ctx.restore()
