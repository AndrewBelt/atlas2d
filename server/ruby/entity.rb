
module Entity
  class << self
    attr_accessor :collection
    
    def create(entity)
      @collection.insert(entity)
    end
    
    # Applies a diff to an entity in the database and broadcasts the change to
    # all subscribers
    #
    # Options: set, unset, exclude
    def update(id, opts={})
      # Update the 
      update_op = {
        '$set' => opts[:set],
        '$unset' => opts[:unset]
      }
      update_op.keep_if {|k, v| v}
      @collection.update({'_id' => id}, update_op)
      
      # Submit the client command
      command = {
        cmd: 'entityUpdate',
        id: id.to_s,
        set: opts[:set],
        unset: opts[:unset]
      }
      command.keep_if {|k, v| v}
      
      exclude = opts[:exclude]
      Connection.all.each do |conn|
        next if exclude and conn == exclude
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
