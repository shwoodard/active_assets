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

    def self.define_tasks
      desc "Generate sprites."
      task :sprites => :environment do
        unless defined?(Rails) && Rails.respond_to?(:application)
          require 'rails/application'
          require 'rails/active_sprites'

          Rails.application = Class.new(Rails::Application)
          Rails.application.extend Rails::ActiveSprites

          sprite_path = 'config/sprites.rb'

          if File.exists?(sprite_path)
            load sprite_path
          else
            exit
          end
        end

        ENV['VERBOSE'] ||= 'true'
        Rails.application.sprites.generate!
      end
    end

  end
end