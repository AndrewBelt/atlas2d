
class Hash
  def deep_merge!(other)
    other.each do |key, value|
      if value.nil?
        # Delete nil values
        self.delete(key)
      elsif value.is_a?(Hash) and self[key].is_a?(Hash)
        # Recursively merge the two hash values
        self[key].deep_merge!(value)
      else
        # Overwrite the scalar directly
        self[key] = value
      end
    end
  end
end


module Entity
  # id => Hash
  @all = {}
  @last_id = 0
  
  class << self
    attr_reader :all
    
    def create(entity)
      @last_id += 1
      id = @last_id
      @all[id] = entity
      Connection.broadcast({cmd: 'entityCreate', id: id, entity: entity})
      return id
    end
    
    def update(id, entity_diff)
      # Deep merge existing entity
      entity = @all.fetch(id)
      entity.deep_merge!(entity_diff)
      Connection.broadcast({cmd: 'entityUpdate', id: id, entity: entity_diff})
    end
    
    def delete(id)
      @all.delete(id)
      Connection.broadcast({cmd: 'entityDelete', id: id})
    end
  end
end
