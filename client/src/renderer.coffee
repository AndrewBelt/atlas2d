
Renderer =
  init: ->
    @inventoryVisible = false
    
    @canvas = $('#game')[0]
    that = @
    $(window).resize ->
      container = $('#main')
      that.resize(container.width(), container.height())
    $(window).resize()
  
  resize: (width, height) ->
    @canvas.width = width
    @canvas.height = height
    # We have to reset the context settings
    @ctx = @canvas.getContext('2d')
    @ctx.mozImageSmoothingEnabled = false
    @ctx.webkitImageSmoothingEnabled = false
    
    # Dimensions of the viewport in tiles
    @viewportSize = new Vector(@canvas.width, @canvas.height).
      div(16 * Game.settings.zoom)
  
  render: ->
    return unless @ctx
    
    try
      @ctx.save()
      # Clear screen
      @ctx.clearRect(0, 0, @canvas.width, @canvas.height)
      @ctx.scale(Game.settings.zoom, Game.settings.zoom)
      
      @renderMap()
      @renderFramerate()
      @renderInventory() if @inventoryVisible
    finally
      @ctx.restore()
  
  renderMap: ->
    try
      @ctx.save()
      # Set up camera crew
      center = if Game.playerId
        player = Game.entities[Game.playerId]
        position = Vector.fromArray(player.location.position)
        position.add(new Vector(0.5, 0.5))
      else
        new Vector()
      viewport = Rect.fromVectors(center.sub(@viewportSize.div(2)), @viewportSize)
      
      # Draw entities
      drawables = @getDrawables()
      for id, drawable of drawables
        box = Rect.fromArrays(drawable.location.position, [1, 1])
        # Only draw the drawable if it will display on the screen
        if viewport.overlaps(box)
          position = box.position().sub(viewport.position()).mul(16)
          Graphic.draw(@ctx, position, drawable.graphic)
    finally
      @ctx.restore()
  
  renderFramerate: ->
    try
      @ctx.save()
      # Draw framerate counter
      fps = 1 / Game.lastDelta
      @ctx.fillStyle = 'orange'
      @ctx.fillRect(0, 0, Math.floor(fps), 4)
      
      @ctx.fillStyle = 'black'
      @ctx.font = '4px monospace'
      @ctx.fillText(fps.toFixed(2), 1, 3)
    finally
      @ctx.restore()
  
  renderInventory: ->
    try
      @ctx.save()
      
      @ctx.fillStyle = 'orange'
      @ctx.fillRect(0, 0, 16*4, 16*4)
      
      index = 0
      for id, entity of Game.entities
        if entity.possession and entity.possession.owner == 0
          position = new Vector(index % 4, Math.floor(index / 4)).mul(16)
          Graphic.draw(@ctx, position, entity.graphic)
          index++
    finally
      @ctx.restore()
  
  getDrawables: ->
    # Filter and sort entities
    drawables = []
    for id, entity of Game.entities
      drawables.push(entity) if entity.location and entity.graphic
    drawables.sort (a, b) ->
      a.location.layer - b.location.layer or
        a.location.position[1] - b.location.position[1]
    drawables
