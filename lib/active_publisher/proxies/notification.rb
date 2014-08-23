module ActivePublisher
  module Proxies
    class Notification
      attr_accessor :messages
      attr_accessor :subscriber
    
      def initialize(subscriber)
        @subscriber = subscriber
      end
    
      def find id
        self.refresh.messages.find {|i| i == id }
      end
    
      def all
        self.refresh.messages
      end
    
      def unread
        ActivePublisher.redis.unread_messages(subscriber)
      end
    
      def refresh
        # Get all notifications
        @messages = ActivePublisher.redis.smembers(@subscriber.active_publisher_key('notifications'))
        self
      end

      protected
        def method_missing(name, *args, &block)
          self.refresh.messages.send(name, *args, &block)
        end

        def messages
          @messages ||= []
        end
    end
  end
end
