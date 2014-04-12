require 'logger'

LOG = Logger.new(STDOUT)
LOG.level = Logger::DEBUG


require './connection'
require './entity'

# Connect to MongoDB
require 'mongo'
mongo = Mongo::MongoClient.new('localhost', 27017)
db = mongo.db('atlas')
Entity.collection = db['entities']

# TEMP
# Initialize entity database
Entity.collection.drop
Entity.create({
  location: {position: [0, 0], layer: 1},
  graphic: {name: 'sand'},
  physics: {collides: true}
})


require 'em-websocket'

# Start the WebSocket server
EventMachine::run do
  EventMachine::WebSocket.run(host: '0.0.0.0', port: 3001) do |ws|
    connection = Connection.new(ws)
  end
end
