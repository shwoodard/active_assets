require 'active_support'

module ActiveAssets
  module ActiveSprites
    extend ActiveSupport::Autoload

    autoload :SpritePiece
    autoload :Sprite
    autoload :Sprites
    autoload :SpriteStylesheet
    autoload :Runner

    def self.load_engine_tasks(engine_class)
      desc "Generate sprites"
      task :sprites do
        require 'rails'
        require 'rails/active_sprites'

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