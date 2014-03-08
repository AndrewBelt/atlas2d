
class Vector
  constructor: (@x=0, @y=0) ->
  add: (vec) ->
    new Vector(@x + vec.x, @y + vec.y)
  sub: (vec) ->
    new Vector(@x - vec.x, @y - vec.y)
  neg: ->
    new Vector(-@x, -@y)
  toString: ->
    "Vector(#{@x}, #{@y})"
  toArray: ->
    [@x, @y]
  @fromArray: (array) ->
    new Vector(array[0], array[1])

class Location
  deserialize: (data) ->
    @position = Vector.fromArray(data.position) if data.position
    @layer = data.layer if data.layer

class Sprite
  constructor: (@img, @source) ->
  drawTo: (ctx, pos) ->
    ctx.drawImage(@img, @source.x*16, @source.y*16, 16, 16,
      pos.x*16, pos.y*16, 16, 16)
