
module Command
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


Command.add 'playerMove' do |args|
  Entity.update(@player_id, {
    location: {
      position: args[:position]
    }
  }, @player_id)
end

Command.add 'chatSend' do |args|
  Connection.broadcast({cmd: 'chatDisplay', text: args[:text]})
end

Command.add 'playerAction' do |args|
  player = Entity.all[@player_id]
  position = player[:location][:position]
  position = [position[0].round, position[1].round]
  id, entity = Entity.all.find do |id, entity|
    entity[:location] and entity[:location][:position] == position and
      id != @player_id
  end
  
  if id
    Entity.update(id, {
      graphic: {
        name: 'rock'
      },
      physics: {
        collides: true
      }
    })
  end
end
