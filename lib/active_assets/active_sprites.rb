require 'active_support'

module ActiveAssets
  module ActiveSprites
    extend ActiveSupport::Autoload

    autoload :SpritePiece
    autoload :Sprite
    autoload :Sprites
    autoload :Configurable
    autoload :SpriteStylesheet
    autoload_under "runners" do
      autoload :AbstractRunner
      autoload :RmagickRunner
      autoload :MiniMagickRunner
      autoload :ChunkyPngRunner
    end

    def self.load_engine_tasks(engine_class)
      desc "Generate sprites"
      task :sprites do
        require 'rails'
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