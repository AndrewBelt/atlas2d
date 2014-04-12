
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


Request.add 'playerMove' do |args|
  position = args['position']
  Entity.update(@player_id, {'location.position' => position})
end

Request.add 'chatSend' do |args|
end

Request.add 'playerAction' do |args|
end
