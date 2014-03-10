require 'set'
require 'json'
require 'em-websocket'


# util.rb

class Vector
  attr_reader :x # Number
  attr_reader :y # Number
  
  class << self
    alias_method :[], :new
    
    # Converts an array with two elements to a Vector
    def from_a(ary)
      new(ary[0], ary[1])
    end
  end
  
  def initialize(x=0, y=0)
    @x = x
    @y = y
  end
  
  def ==(other)
    @x == other.x and @y == other.y
  end
  
  def +(other)
    Vector[@x + other.x, @y + other.y]
  end
  
  def -(other)
    Vector[@x - other.x, @y - other.y]
  end
  
  # Unary negation operator
  def -@
    Vector[-@x, -@y]
  end
  
  # Multiplies self with a scalar or another Vector
  # (element-wise, not dot product)
  def *(other)
    case other
    when Vector
      Vector[@x * other.x, @y * other.y]
    else
      # It's probably a number we can multiply other numbers with.
      Vector[@x * other, @y * other]
    end
  end
  
  alias_method :mul, :*
  
  # Divides self by a scalar or another Vector (element-wise)
  def /(other)
    case other
    when Vector
      Vector[@x / other.x, @y / other.y]
    else
      Vector[@x / other, @y / other]
    end
  end
  
  alias_method :div, :/
  
  def map
    Vector[yield(@x), yield(@y)]
  end
  
  def norm
    Math.hypot(@x, @y)
  end
  
  def normalize
    self / norm
  end
  
  def to_a
    [@x, @y]
  end
  
  def to_json
    to_a.to_json
  end
  
  def inspect
    "Vector[#{@x}, #{@y}]"
  end
end


# entity.rb

class Entity
  @@last_id = 0
  
  class << self
    attr_accessor :all
  end
  
  @all = []
  
  attr_accessor :id
  
  def initialize
    @id = @@last_id += 1
    @components = {}
  end
  
  def [](name)
    @components[name]
  end
  
  def []=(name, component)
    @components[name] = component
  end
  
  def to_json(*args)
    @components.to_json(*args)
  end
end


# components.rb

class Component
  # Converts this Component to a hash, array, or scalar (JSON primitives)
  # This will likely be overridden by subclasses
  def to_json(*args)
    {}.to_json(*args)
  end
end

class Location
  attr_accessor :position # Vector
  attr_accessor :layer # Integer
  
  def initialize(position=Vector[], layer=1)
    @position = position
    @layer = layer
  end
  
  def to_json(*args)
    {
      position: @position.to_a,
      layer: @layer
    }.to_json(*args)
  end
end


# connection.rb

class Connection
  class << self
    attr_reader :all
  end
  
  @all = []
  
  # TODO
  # Entity subscriptions
  
  attr_reader :player
  attr_reader :ws
  
  def initialize(ws)
    @ws = ws
    
    ws.onopen do |handshake|
      Connection.all << self
      connect
    end
    
    ws.onmessage do |msg|
      process(JSON.parse(msg))
    end
    
    ws.onclose do
      close
      Connection.all.delete(self)
    end
  end
  
  def connect
    data = []
    
    Entity.all.each do |entity|
      data << {
        cmd: 'entityCreate',
        id: entity.id,
        entity: entity
      }
    end
    @ws.send data.to_json
    
    @player = Entity.new
    @player[:location] = Location.new(Vector[15, 15], 2)
    @player[:sprite] = 'player'
    Entity.all << @player
    
    Connection.all.each do |conn|
      conn.ws.send([{
        cmd: 'entityCreate',
        id: @player.id,
        entity: @player
      }].to_json)
    end
    
    @ws.send([{
      cmd: 'playerSet',
      id: @player.id
    }].to_json)
  end
  
  def process(data)
    # TEMP
    data = data.last
    
    if data['cmd'] == 'playerMove' and @player
      @player[:location].position = Vector.from_a(data['position'])
      
      # Broadcast position to everyone except self
      Connection.all.each do |conn|
        next if conn == self
        conn.ws.send([{
          cmd: 'entityUpdate',
          id: @player.id,
          entity: {
            location: @player[:location]
          }
        }].to_json)
      end
    end
  end
  
  def close
    Connection.all.each do |conn|
      next if conn == self
      conn.ws.send([{
        cmd: 'entityDelete',
        id: @player.id
      }].to_json)
    end
    
    Entity.all.delete(@player)
  end
end


# main.rb

# Create some initial tiles
30.times do |y|
  30.times do |x|
    e = Entity.new
    e[:location] = Location.new(Vector[x, y], 1)
    e[:sprite] = %w{grass grass2 sand}.sample
    Entity.all << e
  end
end

# Start the WebSocket server
EventMachine::run do
  EventMachine::WebSocket.run(host: '0.0.0.0', port: 8080) do |ws|
    connection = Connection.new(ws)
  end
end
