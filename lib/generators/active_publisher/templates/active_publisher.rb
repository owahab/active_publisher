rails_root = Rails.root || File.dirname(__FILE__) + '/../..'
rails_env = Rails.env || 'development'

redis_config = YAML.load_file("#{ rails_root.to_s }/config/redis.yml")[Rails.env.to_s]
ActivePublisher.redis = redis_config
ActivePublisher.redis.namespace = "activepublisher"