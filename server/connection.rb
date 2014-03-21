require 'set'
require 'json'
require './entity'
require './commands'

class Connection
  @all = Set.new
  
  class << self
    attr_reader :all
    
    def broadcast(command)
      @all.each do |connection|
        connection.sendCommand(command)
      end
    end
  end
  
  attr_reader :subscriptions # Entity IDs
  
  def initialize(ws)
    @subscriptions = Set.new
    @ws = ws
    
    ws.onopen do |handshake|
      Connection.all.add(self)
      connect
      LOG.info "Player connected"
    end
    
    ws.onmessage do |msg|
      process(JSON.parse(msg))
    end
    
    ws.onclose do
      close
      Connection.all.delete(self)
      LOG.info "Player disconnected"
    end
  end
  
  def connect
    # Send all the existing entities to the new player
    commands = []
    Entity.all.each do |id, entity|
      commands << {cmd: 'entityCreate', id: id, entity: entity}
    end
    sendCommands(commands)
    
    # Create player
    @player_id = Entity.create({
      location: {
        position: [0, 0],
        layer: 2
      },
      graphic: {
        name: 'player'
      }
    })
    
    # Set player
    sendCommand({cmd: 'playerSet', id: @player_id})
  end
  
  # Logs the player out and cleans up the Connection for deletion
  def close
    # Delete player
    Entity.delete(@player_id) if @player_id
  end
  
  def process(data)
    data.each do |command|
      runnable = Command[command['cmd']]
      next unless runnable
      command.delete('cmd')
      instance_exec(command, &runnable)
    end
  end
  
  # Sends a single command to the client
  def sendCommand(command)
    @ws.send([command].to_json)
  end
  
  # Sends an array of commands in batch
  def sendCommands(commands)
    @ws.send(commands.to_json)
  end
  
  # TODO
  # Subscriptions not supported yet
  def subscribe(id)
    @subscriptions.add(id)
  end
  
  def unsubscribe(id)
    @subscriptions.delete(id)
  end
end
