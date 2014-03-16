
Renderer =
  init: ->
    @canvas = $('#game-canvas')[0]
    that = @
    window.onresize = ->
      container = $('.game')
      that.resize(container.width(), container.height())
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
    
    # Map
    try
      @ctx.save()
      @ctx.scale(Game.settings.zoom, Game.settings.zoom)
      # Set up camera crew
      center = if Game.playerId
        player = Game.entities[Game.playerId]
        position = Vector.fromArray(player.location.position)
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
    finally
      @ctx.restore()
    
    # HUD
    try
      @ctx.save()
      # Draw framerate counter
      fps = 1 / Game.lastDelta
      @ctx.fillStyle = 'orange'
      @ctx.fillRect(0, 0, Math.floor(fps * 2), 16)
      
      @ctx.fillStyle = 'black'
      @ctx.font = '14px monospace'
      @ctx.fillText(fps.toFixed(2), 2, 12)
    finally
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
