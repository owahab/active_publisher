module ActivePublisher
  class Redis
    attr_reader :store
    
    def initialize(store)
      @store = store
    end
    
    def namespace=(ns)
      require 'redis-namespace'
      @store = ::Redis::Namespace.new(ns, redis: @store)
    end
    
    protected
      def method_missing(name, *args, &block)
        store.send(name, *args, &block)
      end
  end
end