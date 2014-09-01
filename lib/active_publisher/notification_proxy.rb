require 'active_publisher/notification'

module ActivePublisher
  class NotificationProxy
    attr_accessor :messages
    attr_accessor :subscriber
  
    def initialize(subscriber)
      @subscriber = subscriber
    end
  
    def find id
      key = @subscriber.active_publisher_key("notification:#{id}")
      ActivePublisher::Notification.find(key)
    end
  
    def first
      self.find(self.refresh.messages.first)
    end
  
    def last
      self.find(self.refresh.messages.last)
    end
  
    def all
      self.refresh.messages
    end
  
    def to_a
      list = []
      self.refresh.messages.each do |id|
        list << self.find(id)
      end
      list
    end
  
    def unread
      ActivePublisher.redis.unread_messages(subscriber)
    end
  
    def refresh
      # Get notification ids
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
