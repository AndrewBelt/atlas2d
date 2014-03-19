require 'set'
require 'json'
require 'em-websocket'


# connection.rb

class Connection
  class << self
    attr_reader :all
  end
  
  @all = Set.new
  
  attr_reader :ws
  
  def initialize(ws)
    @ws = ws
    
    ws.onopen do |handshake|
      Connection.all.add(self)
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
    10.times do |id|
      sendCommand(
        cmd: 'entityCreate',
        id: id,
        entity: {
          possession: {
            owner: 0
          },
          graphic: {
            name: 'rock'
          }
        }
      )
    end
  end
  
  def process(data)
  end
  
  def close
  end
  
  def sendCommand(data)
    @ws.send([data].to_json)
  end
end


# Start the WebSocket server
EventMachine::run do
  EventMachine::WebSocket.run(host: '0.0.0.0', port: 8080) do |ws|
    connection = Connection.new(ws)
  end
end
