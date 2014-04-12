
# JavaScript

Utils =
  merge: (dest, source, deep=false) ->
    for key, value of source
       # Keys with null and undefined values get deleted
      if !value?
        delete dest[key]
      # Deep copy Objects (including Arrays)
      else if deep and value instanceof Object and dest[key]
        dest[key].length = value.length if value instanceof Array
        @merge(dest[key], value, true)
      else
        dest[key] = value
    dest
  
  set: (hash, key, value) ->
    keys = key.split('.', 2)
    if keys.length == 1
      hash[keys[0]] = value
    else
      @set(hash[keys[0]], keys[1], value)
    console.log(hash, keys, value)
  
  unset: (hash, key) ->
    keys = key.split('.', 2)
    if keys.length == 1
      delete hash[keys[0]]
    else
      @unset(hash[keys[0]], keys[1], value)

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
    Math.abs(@x) + Math.abs(@y)
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
  @fromVectors: (position, size) ->
    new Rect(position.x, position.y, size.x, size.y)
  @fromArrays: (position, size) ->
    new Rect(position[0], position[1], size[0], size[1])
  
  constructor: (@x, @y, @w, @h) ->
  position: ->
    new Vector(@x, @y)
  size: ->
    new Vector(@w, @h)
  
  contains: (vec) ->
    @x <= vec.x <= @x + @w and
      @y <= vec.y <= @y + @h
  includes: (rect) ->
    @x <= rect.x <= @x + @w - rect.w and
      @y <= rect.y <= @y + @h - rect.h
  overlaps: (rect) ->
    @x - rect.w < rect.x < @x + @w and
      @y - rect.h < rect.y < @y + @h
