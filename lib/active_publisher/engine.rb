require 'active_publisher/active_record'
require 'rails'

module ActivePublisher
  class Engine < ::Rails::Engine
    initializer 'active_publisher.configure_rails_initialization' do
      ActiveSupport.on_load(:active_record) do
        ::ActiveRecord::Base.send :include, ActivePublisher::ActiveRecord
      end
    end
  end
end
