module ActivePublisher
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path("../templates", __FILE__)

      def copy_files
        template "active_publisher.rb", "config/initializers/active_publisher.rb"
      end
    end
  end
end