require 'active_publisher/proxies/notification'

module ActivePublisher
  module Models
    module Subscriber
      # Marks the current object as +subscriber+ to the given +publisher+.
      # +publisher+ should be declared as a publisher using +acts_as_publisher+ otherwise throws exception.
      def subscribe publisher
        if publisher.class == String
          ActivePublisher.redis.sadd(ActivePublisher.key(['topics', publisher]), self.active_publisher_key)
          ActivePublisher.redis.sadd(self.active_publisher_key('subscriptions'), ActivePublisher.key(['topics', publisher]))
        elsif publisher.is_a? Object
          raise ActivePublisher::InvalidPublisher unless publisher.respond_to?(:publish)
          raise ActivePublisher::UnpresistedObject unless publisher.id.present?
          ActivePublisher.redis.sadd(publisher.active_publisher_key('subscribers'), self.active_publisher_key)
          ActivePublisher.redis.sadd(self.active_publisher_key('subscriptions'), publisher.active_publisher_key)
        else
          raise ActivePublisher::InvalidPublisher
        end
      end
  
      # Removes +subscriber+ from the given +publisher+ +subscribers+.
      # +publisher+ should be declared as a publisher using +acts_as_publisher+ otherwise throws exception.
      def unsubscribe publisher
        if publisher.class == String
          ActivePublisher.redis.srem(ActivePublisher.key(['topics', publisher]), self.active_publisher_key)
          ActivePublisher.redis.srem(self.active_publisher_key('subscriptions'), ActivePublisher.key(['topics', publisher]))
        elsif publisher.is_a? Object
          raise ActivePublisher::InvalidPublisher unless publisher.respond_to?(:publish)
          raise ActivePublisher::UnpresistedObject unless publisher.id.present?
          ActivePublisher.redis.srem(publisher.active_publisher_key('subscribers'), self.active_publisher_key)
          ActivePublisher.redis.srem(self.active_publisher_key('subscriptions'), publisher.active_publisher_key)
        else
          raise ActivePublisher::InvalidPublisher
        end
      end
      
      def subscriptions
        ActivePublisher.redis.smembers(self.active_publisher_key('subscriptions'))
      end
      
      
      def notifications
        # Return our proxy
        ActivePublisher::Proxies::Notification.new(self)
      end
      
      def receive_notification notification
        subscriber_key = self.active_publisher_key('notifications')
        id = ActivePublisher.redis.incr(self.active_publisher_key('notifications', 'sequence'))
        notification_key = self.active_publisher_key('notification', id)
        # Notify them all
        ActivePublisher.redis.mapped_hmset(notification_key, notification)
        ActivePublisher.redis.sadd(subscriber_key, id)
        begin
          self.deliver_notification id
        rescue ::NoMethodError
          raise ActivePublisher::SubscriberNotAcceptingNotifications
        end
      end
      
      def active_publisher_key *suffix
        key = []
        key << 'subscriber'
        key << self.class.to_s.downcase
        key << self.id
        key << [suffix].flatten! if suffix
        ActivePublisher.key(key)
      end
    end
  end
end