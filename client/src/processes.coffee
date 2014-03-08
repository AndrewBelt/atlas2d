
# Processes

Communicator =
  recvStack: []
  
  init: ->
    url = 'ws://eris.phys.utk.edu:8080/'
    @ws = new WebSocket(url)
    that = this
    
    @ws.onopen = ->
      console.log("Websocket opened")
    @ws.onmessage = (e) ->
      data = JSON.parse(e.data)
      that.recvStack.push(data)
    @ws.onclose = (e) ->
      console.log("Websocket closed")
    @ws.onerror = (e) ->
      console.log("Websocket error", e)
  
  updateData: ->
    # TEMP
    # Quick and hacky
    while data = @recvStack.shift()
      for id, datum of data
        entity = new Entity()
        entity.position = new Vector(datum.position[0], datum.position[1])
        entity.sprite = Game.sprites[datum.sprite]
        Entity.all[id] = entity
        console.log "Added entity \##{id}"
        
        if id == '1'
          Renderer.focus = entity


Controller =
  init: ->
    window.onkeydown = (e) ->
      # TEMP
      # Quick hack to set the screen offset for now
      # (Don't actually send to the Movement process)
      deltaOffset = switch e.keyCode
        when 37 then new Vector(1, 0)
        when 38 then new Vector(0, 1)
        when 39 then new Vector(-1, 0)
        when 40 then new Vector(0, -1)
      Game.settings.offset = Game.settings.offset.add(deltaOffset) if deltaOffset
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
    offset = if @focus
      @focus.position.sub(new Vector(7, 4))
    else
      new Vector()
    
    # Draw entities
    for id, entity of Entity.all
      if entity.sprite and entity.position
        entity.sprite.drawTo(@ctx, entity.position.add(offset))
    
    @ctx.restore()
