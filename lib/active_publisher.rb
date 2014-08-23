require 'redis'
require 'active_publisher/version'
require 'active_publisher/exceptions'
require 'active_publisher/engine'
require 'active_publisher/redis'

module ActivePublisher
  def self.redis=(connection)
    @@redis = ActivePublisher::Redis.new(connection)
  end
  def self.redis
    @@redis
  end
  
  def self.key parts
    parts.reject { |k| k.blank? }.join(':')
  end
  
  def self.load_object_by_key key
    prefix, klass, id, suffix = key.split(':')
    klass.titleize.constantize.find(id)
  end
  
  def self.publish_to_topic topic, notification
    self.redis.smembers(self.key(['topics', topic])).each do |key|
      subscriber = self.load_object_by_key(key)
      subscriber.receive_notification(notification) if subscriber.present?
    end
  end
end