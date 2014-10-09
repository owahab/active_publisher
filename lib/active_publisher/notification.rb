module ActivePublisher
  class Notification
    attr_accessor :id
    attr_accessor :publisher
    attr_accessor :type
    attr_accessor :payload
    
    def self.find(id)
      me = self.new
      n = ActivePublisher.redis.hgetall(id)
      me.id = id.split(':').last
      me.publisher = ActivePublisher.load_object_by_key(n["publisher"])
      me.type = n["type"]
      me.payload = JSON.parse(n["payload"]) if n["payload"].present?
      me
    end
  end
end
