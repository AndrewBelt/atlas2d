require 'logger'

LOG = Logger.new(STDOUT)
LOG.level = Logger::DEBUG


require './connection'
require './entity'

# Initialize landscape
10.times do |y|
  10.times do |x|
    Entity.create({
      location: {
        position: [x, y],
        layer: 1
      },
      graphic: {
        name: 'sand'
      }
    })
  end
end

require 'em-websocket'

# Start the WebSocket server
EventMachine::run do
  EventMachine::WebSocket.run(host: '0.0.0.0', port: 8080) do |ws|
    connection = Connection.new(ws)
  end
end
