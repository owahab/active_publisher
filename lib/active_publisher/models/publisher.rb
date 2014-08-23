module ActivePublisher
  module Models
    module Publisher
      def active_publisher_publish_creating
      end
  
      def active_publisher_publish_updating
      end
  
      def active_publisher_publish_destroying
        
      end
  
      def publish event, payload = {}
        notification = { publisher: self.active_publisher_key, event: event, payload: payload.to_json }
        # Get all subscribers
        self.subscribers.each do |key|
          subscriber = ActivePublisher.load_object_by_key(key)
          subscriber.receive_notification(notification)
        end
      end
      
      def subscribers
        ActivePublisher.redis.smembers(self.active_publisher_key('subscribers'))
      end
      
      def active_publisher_key *suffix
        key = []
        key << 'publisher'
        key << self.class.to_s.downcase
        key << self.id
        key << [suffix].flatten! if suffix
        ActivePublisher.key(key)
      end
    end
  end
end