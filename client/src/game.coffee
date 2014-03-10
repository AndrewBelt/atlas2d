
window.requestAnimationFrame =
  window.requestAnimationFrame or
  window.mozRequestAnimationFrame or
  window.webkitRequestAnimationFrame or
  window.msRequestAnimationFrame


Game =
  settings:
    zoom: 3
    speed: 3 # 15 sanic
  sprites: {}
  player: undefined
  
  init: ->
    Communicator.init()
    Keyboard.init()
    Renderer.init()
  run: ->
    @requestStep()
  requestStep: ->
    that = this
    window.requestAnimationFrame((-> that.step()))
  step: ->
    Movement.move()
    Communicator.processCommands()
    Renderer.render()
    @requestStep()


class Entity
  @all: {}
  
  # Entities may contain any of the below Components as values,
  # with the key name usually the name of the component.
  deserialize: (data) ->
    if data.location
      @location = new Location() unless @location
      @location.deserialize(data.location)
    if data.sprite
      @sprite = Game.sprites[data.sprite]
