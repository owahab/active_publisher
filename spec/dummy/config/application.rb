require File.expand_path('../boot', __FILE__)

require "rails/all"

Bundler.require(*Rails.groups)

module Dummy
  class Application < Rails::Application
    config.encoding = "utf-8"
    config.eager_load = false
    config.cache_classes = true
    config.consider_all_requests_local       = true
    config.action_controller.perform_caching = false
    config.action_dispatch.show_exceptions = false
    config.action_controller.allow_forgery_protection    = false
    config.action_mailer.delivery_method = :test
    config.active_support.deprecation = :stderr
  end
end

