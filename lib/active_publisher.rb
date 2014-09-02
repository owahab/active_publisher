require 'redis/namespace'
require 'active_publisher/version'
require 'active_publisher/exceptions'
require 'active_publisher/engine'

module ActivePublisher
  extend self
  
  # Accepts:
  #   1. A 'hostname:port' String
  #   2. A 'hostname:port:db' String (to select the Redis db)
  #   3. A 'hostname:port/namespace' String (to set the Redis namespace)
  #   4. A Redis URL String 'redis://host:port'
  #   5. An instance of `Redis`, `Redis::Client`, `Redis::DistRedis`,
  #      or `Redis::Namespace`.
  #   6. An Hash of a redis connection {:host => 'localhost', :port => 6379, :db => 0}
  def redis=(server)
    case server
    when String
      if server =~ /redis\:\/\//
        redis = Redis.connect(:url => server, :thread_safe => true)
      else
        server, namespace = server.split('/', 2)
        host, port, db = server.split(':')
        redis = Redis.new(:host => host, :port => port,
          :thread_safe => true, :db => db)
      end
      namespace ||= :activepublisher
      @redis = Redis::Namespace.new(namespace, :redis => redis)
    when Redis::Namespace
      @redis = server
    when Hash
      @redis = Redis::Namespace.new(:resque, :redis => Redis.new(server))
    else
      @redis = Redis::Namespace.new(:resque, :redis => server)
    end
  end

  # Returns the current Redis connection. If none has been created, will
  # create a new one.
  def redis
    return @redis if @redis
    self.redis = Redis.respond_to?(:connect) ? Redis.connect : "localhost:6379"
    self.redis
  end  

  def self.key parts
    parts.reject { |k| k.blank? }.join(':')
  end
  
  def self.load_object_by_key key
    if key
      prefix, klass, id, suffix = key.split(':')
      return klass.titleize.constantize.find(id)
    end
    key
  end
  
  def self.publish_to_topic topic, notification
    self.redis.smembers(self.key(['topics', topic])).each do |key|
      subscriber = self.load_object_by_key(key)
      subscriber.receive_notification(notification) if subscriber.present?
    end
  end
end