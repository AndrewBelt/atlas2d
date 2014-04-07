require 'logger'

LOG = Logger.new(STDOUT)
LOG.level = Logger::DEBUG


require './connection'
require './entity'

# Initialize landscape
# TODO: Landscape generation algorithms
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

#Create non-landscape entity with an event
Entity.create({
  location: {
    position: [1, 1],
    layer: 2
  },
  graphic: {
    name: 'campfire'
  }
  events: [
    {
      #TODO should delete all events after they run, unless they are recurring.
      name: 'burnout'
      interval: 10 #seconds
    }
  ]
})

require 'em-websocket'

# Start the WebSocket server
EventMachine::run do
  EventMachine::WebSocket.run(host: '0.0.0.0', port: 3001) do |ws|
    connection = Connection.new(ws)
  end
end
