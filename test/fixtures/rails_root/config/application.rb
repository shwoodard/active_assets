require 'rails/all'
require 'active_assets/active_expansions/railtie'

module ActiveAssetsTest
  class Application < Rails::Application
    config.root = File.expand_path('../..', __FILE__)
  end
end

Rails.application.config.active_support.deprecation = :stderr
