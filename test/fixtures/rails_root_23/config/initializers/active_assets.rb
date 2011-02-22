require 'rails/active_assets'

Rails.application.extend Rails::ActiveAssets

module ActiveAssets
  module ActiveExpansions
    def self.boot!
      if Rails.application.config.active_expansions.respond_to?(:precache_assets)
        Expansions.precache_assets = Rails.application.config.active_expansions.precache_assets
      end

      options = Rails.application.config.active_expansions
      options.each { |k,v| send("#{k}=", v) }

      load_active_expansions(Rails.root)

      Rails.application.expansions.javascripts.register!
      Rails.application.expansions.stylesheets.register!

      if Expansions.precache_assets
        Rails.application.expansions.javascripts.cache!
        Rails.application.expansions.stylesheets.cache!
      end
    end

    private
      def load_active_expansions(root)
        if File.exists?(File.join(root, 'config/assets.rb'))
          load File.join(root, 'config/assets.rb')
        elsif File.directory?(File.join(root, 'config/assets'))
          Dir[File.join(root, 'config/assets/*.rb')].each do |f|
            load f
          end
        end
      end
  end

  module ActiveSprites
    def self.boot!
      if Rails.application.config.active_sprites.respond_to?(:sprite_backend)
        Sprites.sprite_backend = Rails.application.config.active_sprites.sprite_backend
      end

      load_sprite_definition
    end

    private
      def load_sprite_definition
        config_path = File.join(Rails.root, 'config')
        load File.join(config_path, 'sprites.rb') if File.exists?(File.join(config_path, 'sprites.rb'))
      end
  end
end
