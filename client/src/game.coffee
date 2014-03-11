
window.requestAnimationFrame =
  window.requestAnimationFrame or
  window.mozRequestAnimationFrame or
  window.webkitRequestAnimationFrame or
  window.msRequestAnimationFrame


Game =
  settings:
    zoom: 3
    speed: 3 # 15 sanic
  entities: {}
  sprites: {}
  
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
    Movement.move()
    Communicator.processCommands()
    Renderer.render()
    Communicator.pushRequests() if @frame % 100 == 0
    
    @frame++
    now = new Date()
    @lastFramerate = 1000 / (now - @lastTime) if @lastTime
    @lastTime = now
    
    @requestStep()


# TEMP
class Sprite
  constructor: (@img, @source) ->
  drawTo: (ctx, pos) ->
    dest = pos.mul(16).round()
    ctx.drawImage(@img, @source.x*16, @source.y*16, 16, 16,
      dest.x, dest.y, 16, 16)
