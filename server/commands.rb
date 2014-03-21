
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
      position: args['position']
    }
  })
end


Command.add 'chatSend' do |args|
  Connection.broadcast({cmd: 'chatDisplay', text: args['text']})
end