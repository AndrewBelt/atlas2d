require 'em-websocket'
require 'json'


$position = [0, 0]
$id = 0

def move_player(delta)
  $position[0] += delta[0]
  $position[1] += delta[1]
  puts "Player moved to #{$position}"
  [
    command: 'entityUpdate',
    id: 1,
    entity: {
      location: {
        position: [$position[0], $position[1]]
      }
    }
  ]
end

def generate_commands
  commands = []
  
  commands << {
    command: 'entityCreate',
    id: 1,
    entity: {
      location: {
        position: [$position[0], $position[1]],
        layer: 2
      },
      sprite: 'player'
    }
  }
  
  10.times do |y|
    15.times do |x|
      commands << {
        command: 'entityCreate',
        id: $id += 1,
        entity: {
          location: {
            position: [x, y],
            layer: 1
          },
          sprite: %w{grass grass2}.sample
        }
      }
    end
  end
  commands
end


EM.run do
  EM::WebSocket.run(:host => "0.0.0.0", :port => 8080) do |ws|
    ws.onopen do |handshake|
      puts "WebSocket connection open"
      ws.send generate_commands.to_json
    end
    
    ws.onclose do
      puts "Connection closed"
    end
    
    ws.onmessage do |msg|
      data = JSON.parse(msg)
      if data['command'] = 'movePlayer'
        delta = data['delta']
        ws.send(move_player(delta).to_json)
      end
    end
  end
end
