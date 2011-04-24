# Pick the frameworks you want:
# require 'rails/all'
# require "active_record/railtie"
require "action_controller/railtie"
# require "action_mailer/railtie"
# require "active_resource/railtie"
# require "active_model/railtie"
require "rails/test_unit/railtie"
require 'active_assets/railtie'

module ActiveAssetsTest
  class Application < Rails::Application
    config.root = File.expand_path('../..', __FILE__)
    config.cache_classes = false
    # config.active_expansions.reload_expansions = true
  end
end

# Rails.application.config.active_sprites.sprite_backend = :mini_magick
Rails.application.config.active_support.deprecation = :stderr
