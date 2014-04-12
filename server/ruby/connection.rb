require 'set'
require 'json'
require './entity'
require './requests'

class Connection
  @all = Set.new
  
  class << self
    attr_reader :all
    
    def broadcast(command)
      @all.each do |conn|
        conn.push_command(command)
      end
    end
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
      JSON.parse(msg).each do |request|
        run_request(request)
      end
    end
    
    ws.onclose do
      close
      Connection.all.delete(self)
      LOG.info "Player disconnected"
    end
  end
  
  def connect
    # Send welcome message
    push_command({cmd: 'chatDisplay', text: 'Welcome to Atlas 2D!'})
    
    # Note: The rest of the client setup is in the 'login' request.
    # The client sends this once it's ready to begin playing.
  end
  
  # Cleans up the Connection for deletion
  def close
    run_request({cmd: 'logout'})
  end
  
  # Add the id to the subscriptions list
  # and create the entity on the client
  def subscribe(id)
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
  
  def run_request(request)
    runnable = Request[request['cmd']]
    return false unless runnable
    request.delete(:cmd)
    instance_exec(request, &runnable)
  end
  
  # Sends a single command to the client
  def push_command(command)
    # TEMP
    # Send the data immediately
    @ws.send([command].to_json)
    
    # TODO
    # Send the data in bulk when the request proc is finished, not all at once
  end
end
