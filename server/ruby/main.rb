require 'rubygems'
require 'bundler/setup'

require 'logger'

LOG = Logger.new(STDOUT)
LOG.level = Logger::DEBUG
LOG.formatter = Proc.new do |severity, datetime, progname, msg|
  "#{severity}: #{msg}\n"
end


require './connection'
require './entity'


# Connect to MongoDB
LOG.info "Connecting to MongoDB..."
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


# Start the WebSocket server
require 'em-websocket'
EventMachine::run do
  port = 3001
  LOG.info "Starting WebSocket server on port #{port}..."
  
  EventMachine::WebSocket.run(host: '0.0.0.0', port: port) do |ws|
    connection = Connection.new(ws)
  end
  
  LOG.info "Server started. Have fun!"
end
