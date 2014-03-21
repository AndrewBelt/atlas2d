
# Maintains a constant controller state
Controller =
  init: ->
    @pressedKeys = {}
    that = @
    
    $(window).keydown (e) ->
      that.pressedKeys[e.keyCode] = true
      that.checkKey(e.keyCode)
    $(window).keyup (e) ->
      delete that.pressedKeys[e.keyCode]
    $(window).blur ->
      that.pressedKeys = {}
    
    # Disable tablet scrolling
    $(document).bind 'touchmove', (e) ->
      e.preventDefault()
  
  isPressed: (key) ->
    @pressedKeys[key]?
  
  checkKey: (key) ->
    switch key
      when 16 # shift
        Renderer.inventoryVisible ^= true
      when 32 # space
        Request.action()
