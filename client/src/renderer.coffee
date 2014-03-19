
Renderer =
  init: ->
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
    
    @viewportSize = new Vector(@canvas.width, @canvas.height).
      div(16 * Game.settings.zoom)
  
  render: ->
    return unless @ctx
    
    try
      @ctx.save()
      # Clear screen
      @ctx.clearRect(0, 0, @canvas.width, @canvas.height)
      @ctx.scale(Game.settings.zoom, Game.settings.zoom)
      
      # @renderMap()
      # @renderFramerate()
    finally
      @ctx.restore()
  
  renderMap: ->
    try
      @ctx.save()
      # Set up camera crew
      center = if Game.playerId
        player = Game.entities[Game.playerId]
        position = Vector.fromArray(player.location.position)
        position.addBy(new Vector(0.5, 0.5))
      else
        new Vector()
      viewport = new Rect(center.sub(@viewportSize.div(2)), @viewportSize)
      
      # Draw entities
      drawables = @getDrawables()
      for id, drawable of drawables
        box = new Rect(Vector.fromArray(drawable.location.position), new Vector(1, 1))
        # Only draw the drawable if it will display on the screen
        if viewport.overlaps(box)
          position = box.position.sub(viewport.position)
          graphic = Game.graphics[drawable.graphic.name]
          graphic.draw(@ctx, position, drawable.graphic)
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
  
  getDrawables: ->
    # Filter and sort entities
    drawables = []
    for id, entity of Game.entities
      drawables.push(entity) if entity.location and entity.graphic
    drawables.sort (a, b) ->
      a.location.layer - b.location.layer or
        a.location.position[1] - b.location.position[1]
    drawables
