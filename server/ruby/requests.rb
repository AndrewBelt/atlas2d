
module Request
  # name => Proc
  @all = {}
  
  class << self
    def add(name, &block)
      @all[name] = block
    end
    
    def [](name)
      @all[name]
    end
  end
end


Request.add 'login' do |args|
  # TODO
  # Check for login credentials, etc.
  
  # TEMP
  # Subscribe to existing entities
  # (Question: Couldn't this^ make the game quite vulnerable to global visibility hacks?)
  # Answer: Yup. We need to add more advanced entity subscription algorithms.
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
  
  # Set player
  Connection.all.each do |conn|
    conn.subscribe(@player_id)
  end
  push_command({cmd: 'playerSet', id: @player_id.to_s})
end


Request.add 'logout' do |args|
  # Delete player
  Entity.delete(@player_id) if @player_id
end


Request.add 'playerMove' do |args|
  position = args['position']
  Entity.update(@player_id, {'location.position' => position})
end


Request.add 'chatSend' do |args|
  text = args['text']
  LOG.debug "Player said: \"#{text}\""
  Connection.broadcast({cmd: 'chatDisplay', text: text})
end


Request.add 'playerAction' do |args|
end
