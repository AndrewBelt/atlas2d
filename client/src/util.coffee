
# JavaScript

Utils =
  merge: (dest, source, deep=false) ->
    for key, value of source
       # Keys with null and undefined values get deleted
      if !value?
        delete dest[key]
      # Deep copy Objects (including Arrays)
      else if deep and value instanceof Object
        dest[key].length = value.length if value instanceof Array
        @merge(dest[key], value, true)
      else
        dest[key] = value
    dest

# Math

class Vector
  @fromArray: (array) ->
    new Vector(array[0], array[1])
  
  constructor: (@x=0, @y=0) ->
  
  # Zerary operators
  clone: ->
    new Vector(@x, @y)
  round: ->
    new Vector(Math.round(@x), Math.round(@y))
  floor: ->
    new Vector(Math.floor(@x), Math.floor(@y))
  
  # Unary operators
  neg: ->
    new Vector(-@x, -@y)
  
  # Binary operators
  add: (vec) ->
    new Vector(@x + vec.x, @y + vec.y)
  sub: (vec) ->
    new Vector(@x - vec.x, @y - vec.y)
  mul: (a) ->
    new Vector(@x * a, @y * a)
  div: (a) ->
    new Vector(@x / a, @y / a)
  
  # In-place operators
  addBy: (vec) ->
    @x += vec.x
    @y += vec.y
  mulBy: (a) ->
    @x *= a
    @y *= a
  
  # Test methods
  isZero: ->
    @x == 0 and @y == 0
  isEqual: (vec) ->
    @x == vec.x and @y == vec.y
  
  # L0 distance
  min: ->
    Math.min(Math.abs(@x), Math.abs(@y))
  # L1 distance
  sum: ->
    @x + @y
  # L2 distance
  norm: ->
    Math.sqrt(@x*@x + @y*@y)
    # Math.hypot(@x, @y)
  # L-infinity distance
  max: ->
    Math.max(Math.abs(@x), Math.abs(@y))
  normalize: ->
    @div(@norm())
  
  toString: ->
    "Vector(#{@x}, #{@y})"
  toArray: ->
    [@x, @y]


class Rect
  constructor: (@position, @size) ->
  contains: (vec) ->
    @position.x <= vec.x <= @position.x + @size.x and
      @position.y <= vec.y <= @position.y + @size.y
  includes: (rect) ->
    @position.x <= rect.position.x <= @position.x + @size.x - rect.size.x and
      @position.y <= rect.position.y <= @position.y + @size.y - rect.size.y
  overlaps: (rect) ->
    @position.x - rect.size.x < rect.position.x < @position.x + @size.x and
      @position.y - rect.size.y < rect.position.y < @position.y + @size.y
