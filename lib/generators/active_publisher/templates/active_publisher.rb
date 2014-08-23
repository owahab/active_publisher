rails_root = Rails.root || File.dirname(__FILE__) + '/../..'
rails_env = Rails.env || 'development'

redis_config = YAML.load_file("#{ rails_root.to_s }/config/redis.yml")[Rails.env.to_s]
if redis_config.is_a?(String)
  ActivePublisher.redis = Redis.new(url: redis_config)
else
  ActivePublisher.redis = Redis.new(host: redis_config[:host], port: redis_config[:port], password: redis_config[:password])
end
ActivePublisher.redis.namespace = "activepublisher"