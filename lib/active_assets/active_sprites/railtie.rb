require 'rails'
require 'rails/railtie'
require 'rails/active_sprites'
require 'active_assets/active_sprites'

module ActiveAssets
  module ActiveSprites
    class Railtie < Rails::Railtie
      config.active_sprites = ActiveSupport::OrderedOptions.new

      rake_tasks do
        Dir[File.expand_path("../../../tasks/active_sprites/*.rake", __FILE__)].each {|f| load f}
      end

      initializer 'active_sprites-extend-application' do
        Rails.application.extend(Rails::ActiveSprites)
      end

      initializer 'active_sprites-load-definitons' do
        Rails.application.config.paths.config.paths.each {|config_path| load_sprite_definition(config_path) }
        if config.active_sprites.load_engine_sprite_definitions
          Rails.application.railties.engines.map(&:config).map(&:paths).map(&:config).map(&:paths).each do |config_path|
            load_sprite_definition(config_path)
          end
        end
      end

      initializer 'active_sprites-set-configs' do
        options = config.active_sprites
        ActiveSupport.on_load(:active_sprites) do
          options.each { |k,v| send("#{k}=", v) }
        end
      end

      private
        def load_sprite_definition(config_path)
          load File.join(config_path, 'sprites.rb') if File.exists?(File.join(config_path, 'sprites.rb'))
        end
    end
  end
end