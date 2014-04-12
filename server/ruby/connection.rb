require 'set'
require 'json'
require './entity'
require './requests'

class Connection
  @all = Set.new
  
  class << self
    attr_reader :all
  end
  
  attr_reader :subscriptions # [ID]
  attr_reader :player_id # ID
  
  def initialize(ws)
    @subscriptions = Set.new
    @ws = ws
    
    ws.onopen do |handshake|
      Connection.all.add(self)
      connect
      LOG.info "Player connected"
    end
    
    ws.onmessage do |msg|
      process_requests(JSON.parse(msg))
    end
    
    ws.onclose do
      close
      Connection.all.delete(self)
      LOG.info "Player disconnected"
    end
  end
  
  def connect
    # TEMP
    # Subscribe to existing entities
    # (Question: Couldn't this^ make the game quite vulnerable to global visibility hacks?)
    # Answer: Yes.
    Entity.collection.find.each do |entity|
      subscribe(entity['_id'])
    end
    
    # TEMP
    # Create player
    @player_id = Entity.create({
      location: {
        position: [0, -1],
        layer: 2
      },
      graphic: {
        name: 'player'
      },
      skills: {
        #skillName: skillLevel
        woodworking: 20
      },
      gems: {
        #gemName: gemLevel
        earth: 34,
        fire: 0
      }
    })
    
    # Send welcome message
    push_command({cmd: 'chatDisplay', text: 'You are now connected to Atlas 2d!'})
    
    # Set player
    Connection.all.each do |conn|
      conn.subscribe(@player_id)
    end
    push_command({cmd: 'playerSet', id: @player_id.to_s})
  end
  
  # Logs the player out and cleans up the Connection for deletion
  def close
    # Delete player
    Entity.delete(@player_id) if @player_id
  end
  
  # Add the id to the subscriptions list
  # and create the entity on the client
  def subscribe(id)
    # TEMP
    # The database shouldn't be queried one at a time.
    entity = Entity.collection.find_one({'_id' => id})
    return unless entity
    
    entity.delete('_id')
    push_command({cmd: 'entityCreate', id: id.to_s, entity: entity})
    @subscriptions.add(id)
  end
  
  # Remove the id from the subscriptions list
  # and delete the entity from the client
  def unsubscribe(id)
    push_command({cmd: 'entityDelete', id: id.to_s})
    @subscriptions.delete(id)
  end
  
  def process_requests(requests)
    requests.each do |request|
      runnable = Request[request['cmd']]
      next unless runnable
      request.delete(:cmd)
      instance_exec(request, &runnable)
    end
  end
  
  # Sends a single command to the client
  def push_command(command)
    # TEMP
    # Send the data immediately
    @ws.send([command].to_json)
    
    # TODO
    # Send the data once the command is finished
  end
end
