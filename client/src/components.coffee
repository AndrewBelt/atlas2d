
class Component

class Vector extends Component
  constructor: (@x=0, @y=0) ->
  add: (vec) ->
    new Vector(@x + vec.x, @y + vec.y)
  sub: (vec) ->
    new Vector(@x - vec.x, @y - vec.y)
  neg: ->
    new Vector(-@x, -@y)
  toString: ->
    "Vector(#{@x}, #{@y})"

class Sprite extends Component
  constructor: (@img, @source=new Vector()) ->
  drawTo: (ctx, pos) ->
    ctx.drawImage(@img, @source.x*16, @source.y*16, 16, 16,
      pos.x*16, pos.y*16, 16, 16)
