
module Entity
  class << self
    attr_accessor :collection
    
    def create(entity)
      return @collection.insert(entity)
    end
    
    # Set and unset hashes should look like
    # {'location.position' => [1, 2]}
    def update(id, set=nil, unset=nil)
      update_op = {}
      update_op['$set'] = set if set
      update_op['$unset'] = unset if unset
      @collection.update({'_id' => id}, update_op)
      
      # Submit the client command
      command = {cmd: 'entityUpdate', id: id.to_s}
      command['set'] = set if set
      command['unset'] = unset if unset
      
      Connection.all.each do |conn|
        if conn.subscriptions.include?(id)
          conn.push_command(command)
        end
      end
    end
    
    def delete(id)
      @collection.remove({'_id' => id})
      
      # TODO
      # Submit the client command
    end
  end
end
