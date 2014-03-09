
Game =
  settings:
    fps: 30
    # speed: 15 # sanic
    speed: 5
  sprites: {}
  player: undefined
  
  init: ->
    Communicator.init()
    Keyboard.init()
    Renderer.init()
  run: ->
    that = this
    window.setInterval((-> that.step()), 1000/@settings.fps)
  step: ->
    Movement.move()
    Communicator.processCommands()
    Renderer.render()


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
