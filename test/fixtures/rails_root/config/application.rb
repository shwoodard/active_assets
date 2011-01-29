require 'rails/all'
require 'active_assets/railtie'

module ActiveAssetsTest
  class Application < Rails::Application
    config.root = File.expand_path('../..', __FILE__)
  end
end

Rails.application.config.active_sprites.sprite_backend = :chunky_png
Rails.application.config.active_support.deprecation = :stderr
