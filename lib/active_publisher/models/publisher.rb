module ActivePublisher
  module Models
    module Publisher
      def active_publisher_publish_creating
      end
  
      def active_publisher_publish_updating
      end
  
      def active_publisher_publish_destroying
        
      end
  
      def publish events, payload = {}
        events.each do |event|
          notification = { publisher: self.active_publisher_key(event), payload: payload.to_json}
          # Get all subscribers
          self.subscribers(event).uniq.each do |key|
            subscriber = ActivePublisher.load_object_by_key(key)
            subscriber.receive_notification(notification)
          end
        end
      end
      
      def subscribers *events
        ActivePublisher.redis.sunion(events.map {|event| self.active_publisher_key(event, 'subscribers')}.join(' '))
      end
      
      def active_publisher_key event, *suffix
        key = []
        key << 'publisher'
        key << self.class.to_s.downcase
        key << self.id
        key << [suffix].flatten! if suffix
        key << event.to_s if !event.nil? && !event.empty?
        ActivePublisher.key(key)
      end
    end
  end
end