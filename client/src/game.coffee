
window.requestAnimationFrame =
  window.requestAnimationFrame or
  window.mozRequestAnimationFrame or
  window.webkitRequestAnimationFrame or
  window.msRequestAnimationFrame


Game =
  settings:
    zoom: 4
    speed: 2 # 15 sanic
  entities: {}
  graphics: {}
  
  init: ->
    Network.init()
    Controller.init()
    Renderer.init()
    GUI.init()
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
    @lastDelta = (now - @lastTime) / 1000 if @lastTime
    @lastTime = now
    
    Movement.move()
    Network.processCommands()
    Renderer.render()
    Network.pushRequests() if @frame % 2 == 0
    
    @requestStep()


class Graphic
  constructor: (@image, data) ->
    if data instanceof Array
      @coords = Vector.fromArray(data)
    else
      @animations = {}
      for name, animation of data.animations
        @animations[name] = for frame in animation
          Vector.fromArray(frame)
      
      @delay = data.delay or 1
      @size = if data.size then Vector.fromArray(data.size) else new Vector(1, 1)
      @offset = if data.offset then Vector.fromArray(data.offset) else new Vector(0, 0)
      @default = data.default
  
  draw: (ctx, pos, graphicData) ->
    # Mini graphic
    if @coords?
      dest = pos.mul(16).round()
      ctx.drawImage(@image, @coords.x*16, @coords.y*16, 16, 16,
        dest.x, dest.y, 16, 16)
    
    # Full graphic
    else
      dest = pos.sub(@offset).mul(16).round()
      animation = @animations[graphicData.animation]
      animation = @animations[@default] unless animation
      # Fail silently if no animation is found
      return unless animation
      
      frameIndex = if !graphicData.animating then 0
      else
        subframe = graphicData.subframe or 0
        frame = graphicData.frame or 0
        # Advance the graphic component's frame upon drawing
        graphicData.frame = (frame + 1) % (animation.length * @delay)
        Math.floor(frame / @delay)
      
      source = animation[frameIndex].mul(16)
      
      size = @size.mul(16)
      ctx.drawImage(@image, source.x, source.y, size.x, size.y,
        dest.x, dest.y, size.x, size.y)
