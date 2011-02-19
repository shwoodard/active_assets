require 'active_support'

module ActiveAssets
  module ActiveSprites
    autoload :SpritePiece, 'active_assets/active_sprites/sprite_piece'
    autoload :Sprite, 'active_assets/active_sprites/sprite'
    autoload :Sprites, 'active_assets/active_sprites/sprites'
    autoload :Configurable, 'active_assets/active_sprites/configurable'
    autoload :SpriteStylesheet, 'active_assets/active_sprites/sprite_stylesheet'
    autoload :AbstractRunner, 'active_assets/active_sprites/runners/abstract_runner'
    autoload :RmagickRunner, 'active_assets/active_sprites/runners/rmagick_runner'
    autoload :MiniMagickRunner, 'active_assets/active_sprites/runners/mini_magick_runner'
    autoload :ChunkyPngRunner, 'active_assets/active_sprites/runners/chunky_png_runner'

    def self.load_engine_tasks(engine_class)
      desc "Generate sprites"
      task :sprites do
        require 'rails/application'
        require 'rails/active_sprites'

        ENV['VERBOSE'] ||= 'true'

        Rails.application ||= Class.new(Rails::Application)
        Rails.application.extend Rails::ActiveSprites

        engine = engine_class.new
        sprite_path = File.join(engine.config.paths.config.paths.first, 'sprites.rb')

        if File.exists?(sprite_path)
          load sprite_path
          Rails.application.sprites.generate!(engine)
        end
      end
    end

  end
end