
window.requestAnimationFrame =
  window.requestAnimationFrame or
  window.mozRequestAnimationFrame or
  window.webkitRequestAnimationFrame or
  window.msRequestAnimationFrame


Game =
  settings:
    zoom: 3
    speed: 2 # 15 sanic
  entities: {}
  graphics: {}
  
  init: ->
    Communicator.init()
    Controller.init()
    Renderer.init()
  run: ->
    @frame = 0
    @requestStep()
  requestStep: ->
    that = this
    window.requestAnimationFrame((-> that.step()))
  step: ->
    # Advance frame and update framerate
    @frame++
    now = new Date()
    @lastFramerate = 1000 / (now - @lastTime) if @lastTime
    @lastTime = now
    
    try
      Movement.move()
      Communicator.processCommands()
      Renderer.render()
      Communicator.pushRequests() if @frame % 2 == 0
    catch error
      console.log("Error in game loop: #{error}")
    
    @requestStep()


# TEMP
class StaticGraphic
  draw: (ctx, pos, graphicData) ->
    dest = pos.mul(16).round()
    ctx.drawImage(@image, @source.x*16, @source.y*16, 16, 16,
      dest.x, dest.y, 16, 16)

class AnimatedGraphic
  draw: (ctx, pos, graphicData) ->
    frame = graphicData.frame or 0
    source = @frames[Math.floor(frame / @delay)].mul(16)
    
    # Advance the graphic component's frame upon drawing
    graphicData.frame = (frame + 1) % (@frames.length * @delay)
    
    dest = pos.mul(16).round()
    size = @size.mul(16)
    ctx.drawImage(@image, source.x, source.y, size.x, size.y,
      dest.x, dest.y, size.x, size.y)
