
module Entity
  class << self
    attr_accessor :collection
    
    def create(entity)
      return @collection.insert(entity)
    end
    
    # Set and unset hashes should look like
    # {'location.position' => [1, 2]}
    def update(id, set=nil, unset=nil)
      update_op = {
        '$set' => set,
        '$unset' => unset
      }
      update_op.keep_if {|k, v| v}
      @collection.update({'_id' => id}, update_op)
      
      # Submit the client command
      command = {
        cmd: 'entityUpdate',
        id: id.to_s,
        set: set,
        unset: unset
      }
      command.keep_if {|k, v| v}
      
      Connection.all.each do |conn|
        if conn.subscriptions.include?(id)
          conn.push_command(command)
        end
      end
    end
    
    def delete(id)
      @collection.remove({'_id' => id})
      
      # Submit the client command
      command = {cmd: 'entityDelete', id: id}
      Connection.all.each do |conn|
        if conn.subscriptions.include?(id)
          conn.push_command(command)
        end
      end
    end
  end
end
