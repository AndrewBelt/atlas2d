require 'em-websocket'
require 'json'


$id = 0

def generate_data
  data = {}
  
  data[$id += 1] = {
    position: [7, 4],
    sprite: 'player'
  }
  
  10.times do |y|
    15.times do |x|
      data[$id += 1] = {
        position: [x, y],
        sprite: %w{grass grass2 sand water}.sample
      }
    end
  end
  data
end

data = generate_data


def new_data
  data = {}
  data[$id += 1] = {
    position: [Random.rand(15), Random.rand(10)],
    sprite: %w{grass grass2 sand water}.sample
  }
  data
end


EM.run do
  EM::WebSocket.run(:host => "0.0.0.0", :port => 8080) do |ws|
    ws.onopen do |handshake|
      puts "WebSocket connection open"
      ws.send data.to_json
    end
    
    ws.onclose do
      puts "Connection closed"
    end
    
    ws.onmessage do |msg|
      puts "Recieved message: #{msg}"
    end
  end
end
