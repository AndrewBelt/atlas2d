
# Processes

Communicator =
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
    if @ws.readyState == 1 and Request.requestStack.length > 0
      json = JSON.stringify(Request.requestStack)
      @ws.send(json)
      console.log("Sent #{json.length} bytes") if @log
      Request.requestStack.length = 0
  
  processCommands: ->
    while args = @commandStack.shift()
      command = args.cmd
      delete args.cmd
      @commands[command](args)
  
  ## Commands (server --> client)
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
    chatDisplay: (args) ->
      GUI.chatDisplay(args.text)


## Requests (client --> server)
Request =
  requestStack: []
  
  playerMove: (position) ->
    @requestStack.push {
      cmd: 'playerMove',
      position: position.toArray()
    }
  
  chatSend: (text) ->
    @requestStack.push {
      cmd: 'chatSend',
      text: text
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
    
    # Disable tablet scrolling
    document.addEventListener 'touchmove', (e) ->
      e.preventDefault()
  
  isPressed: (key) ->
    @keys[key]?


Renderer =
  init: ->
    @canvas = document.getElementById('main')
    console.log @canvas
    
    that = @
    window.onresize = ->
      that.resize(document.body.clientWidth, document.body.clientHeight)
    window.onresize()
  
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
    
    drawables = @drawables()
    
    # Draw entities
    for id, drawable of drawables
      box = new Rect(Vector.fromArray(drawable.location.position), new Vector(1, 1))
      # Only draw the drawable if it will display on the screen
      if viewport.overlaps(box)
        position = box.position.sub(viewport.position)
        graphic = Game.graphics[drawable.graphic.name]
        graphic.draw(@ctx, position, drawable.graphic)
    
    @ctx.restore()
  
  drawables: ->
    # Filter and sort entities
    drawables = []
    for id, entity of Game.entities
      drawables.push(entity) if entity.location and entity.graphic
    drawables.sort (a, b) ->
      (a.location.layer - b.location.layer) or
        a.location.position[1] - b.location.position[1]
    drawables


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
      
      Game.player.location.position = position.toArray()
      Request.playerMove(position)
