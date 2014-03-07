
class Entity
  @all: {}
  
  # Entities may contain any of the below Components as values,
  # with the key name usually the name of the component.


class Vector
  constructor: (@x=0, @y=0) ->
  add: (vec) ->
    new Vector(@x + vec.x, @y + vec.y)
  sub: (vec) ->
    new Vector(@x - vec.x, @y - vec.y)
  neg: ->
    new Vector(-@x, -@y)
  toString: ->
    "(#{@x}, #{@y})"

class Sprite
  constructor: (@img, sx=0, sy=0) ->
    @s = new Vector(sx, sy)
  drawTo: (ctx, pos) ->
    ctx.drawImage(@img, @s.x*16, @s.y*16, 16, 16,
      pos.x*16, pos.y*16, 16, 16)
