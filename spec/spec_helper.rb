ENV["RAILS_ENV"] = "test"

# add dummy to the load path. now we're also at the root of the fake rails app.
app_path = File.expand_path("../dummy",  __FILE__)
$LOAD_PATH.unshift(app_path) unless $LOAD_PATH.include?(app_path)

require 'rails/all'
require 'config/environment'
require 'db/schema'
require 'rspec/rails'
require 'factory_girl_rails'
require 'database_cleaner'
require 'active_publisher'

Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

RSpec.configure do |config|
  config.mock_with :rspec
  config.order = :random
  config.fixture_path = "#{File.dirname(__FILE__)}/factories.rb"
  config.filter_run focus: true
  config.filter_run_excluding disable: true
  config.run_all_when_everything_filtered = true
  config.include MailerMacros
  
  # Configure DatabaseCleaner
  DatabaseCleaner[:redis, connection: 'redis://localhost:6379']
  DatabaseCleaner.strategy = :truncation
  config.after(:each) do
    DatabaseCleaner.clean
  end
  
end