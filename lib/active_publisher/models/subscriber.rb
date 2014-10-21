require 'active_publisher/notification_proxy'

module ActivePublisher
  module Models
    module Subscriber
      # Marks the current object as +subscriber+ to the given +publisher+.
      # +publisher+ should be declared as a publisher using +acts_as_publisher+ otherwise throws exception.
      def subscribe publisher, *events
        if publisher.class == String
          ActivePublisher.redis.sadd(ActivePublisher.key(['topics', publisher]), self.active_publisher_key(''))
          ActivePublisher.redis.sadd(self.active_publisher_key('', 'subscriptions'), ActivePublisher.key(['topics', publisher]))
        elsif publisher.is_a? Object
          raise ActivePublisher::InvalidPublisher unless publisher.respond_to?(:publish)
          raise ActivePublisher::UnpresistedObject unless publisher.id.present?
          events.each do |event|
            ActivePublisher.redis.sadd(publisher.active_publisher_key(event, 'subscribers'), self.active_publisher_key(event))
            return ActivePublisher.redis.sadd(self.active_publisher_key(event, 'subscriptions'), publisher.active_publisher_key(event))
          end
        else
          raise ActivePublisher::InvalidPublisher
        end
      end
  
      # Removes +subscriber+ from the given +publisher+ +subscribers+.
      # +publisher+ should be declared as a publisher using +acts_as_publisher+ otherwise throws exception.
      def unsubscribe publisher, *events
        if publisher.class == String
          ActivePublisher.redis.srem(ActivePublisher.key(['topics', publisher]), self.active_publisher_key(''))
          ActivePublisher.redis.srem(self.active_publisher_key('', 'subscriptions'), ActivePublisher.key(['topics', publisher]))
        elsif publisher.is_a? Object
          raise ActivePublisher::InvalidPublisher unless publisher.respond_to?(:publish)
          raise ActivePublisher::UnpresistedObject unless publisher.id.present?
          events.each do |event|
            ActivePublisher.redis.srem(publisher.active_publisher_key(event, 'subscribers'), self.active_publisher_key(event))
            return ActivePublisher.redis.srem(self.active_publisher_key(event, 'subscriptions'), publisher.active_publisher_key(event))
          end
        else
          raise ActivePublisher::InvalidPublisher
        end
      end
      
      def subscriptions *events
        ActivePublisher.redis.sunion(events.map {|event| self.active_publisher_key(event, 'subscriptions')}.join(' '))
      end
      
      
      def notifications
        # Return our proxy
        ActivePublisher::NotificationProxy.new(self)
      end

      def mark_notifications_read
        subscriber_key = self.active_publisher_key('', 'notifications', 'unread')
        ActivePublisher.redis.del(subscriber_key)
      end
      
      def receive_notification notification
        subscriber_key = self.active_publisher_key('', 'notifications')
        id = ActivePublisher.redis.incr(self.active_publisher_key('', 'notifications', 'sequence'))
        notification_key = self.active_publisher_key('', 'notification', id)
        # Notify them all
        ActivePublisher.redis.mapped_hmset(notification_key, notification)
        ActivePublisher.redis.sadd(subscriber_key, id)
        ActivePublisher.redis.sadd(self.active_publisher_key('', 'notifications', 'unread'), id)
        begin
          self.deliver_notification id
        rescue ::NoMethodError
          raise ActivePublisher::SubscriberNotAcceptingNotifications
        end
      end
      
      def active_publisher_key event, *suffix
        key = []
        key << 'subscriber'
        key << self.class.to_s.downcase
        key << self.id
        key << [suffix].flatten! if suffix
        key << event.to_s if !event.nil? && !event.empty?
        ActivePublisher.key(key)
      end
    end
  end
end