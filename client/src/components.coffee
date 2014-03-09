
class Vector
  @fromArray: (array) ->
    new Vector(array[0], array[1])
  
  constructor: (@x=0, @y=0) ->
  
  # Unary operators
  neg: ->
    new Vector(-@x, -@y)
  
  # Binary operators
  add: (vec) ->
    new Vector(@x + vec.x, @y + vec.y)
  addto: (vec) ->
    @x += vec.x
    @y += vec.y
  sub: (vec) ->
    new Vector(@x - vec.x, @y - vec.y)
  mul: (a) ->
    new Vector(@x * a, @y * a)
  div: (a) ->
    new Vector(@x / a, @y / a)
  
  # Functions
  norm: ->
    Math.sqrt(@x*@x + @y*@y)
    # Math.hypot(@x, @y)
  normalize: ->
    @div(@norm())
  quantize: ->
    new Vector(Math.floor(@x), Math.floor(@y))
  toString: ->
    "Vector(#{@x}, #{@y})"
  toArray: ->
    [@x, @y]

class Location
  deserialize: (data) ->
    @position = Vector.fromArray(data.position) if data.position
    @layer = data.layer if data.layer

class Sprite
  constructor: (@img, @source) ->
  drawTo: (ctx, pos) ->
    dest = pos.mul(16)#.quantize()
    ctx.drawImage(@img, @source.x*16, @source.y*16, 16, 16,
      dest.x, dest.y, 16, 16)
