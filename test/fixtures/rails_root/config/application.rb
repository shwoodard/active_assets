require 'rails/all'
require 'active_assets/railtie'

module ActiveAssets
  class Application < Rails::Application
    config.root = File.expand_path('../..', __FILE__)
  end
end

Rails.application.config.active_support.deprecation = :stderr
