require 'action_view'

module ActiveAssets
  module ActiveSprites
    class Runner
      class AssetContext < ActionView::Base
      end

      def initialize(sprites)
        @controller = ActionController::Base.new
        @context = AssetContext.new(Rails.application.config.action_controller, {}, @controller)

        @sprites = if ENV['SPRITE']
          sprites.select do |name, sprite|
            ENV['SPRITE'].split(',').map(&:compact).each do |sp|
              # were going to be very forgiving
              name == sp ||
              name == sp.to_sym ||
              name == ::Rack::Mount::Utils.normalize_path(sp)
            end
          end
        else
          sprites.values
        end
      end

      def generate!(debug = ENV['DEBUG'])
        @sprites.each do |sprite|
          sprite_path = context.image_path(sprite.path)
          p "Sprite Path: #{sprite_path}" if debug
          sprite_stylesheet_path = context.stylesheet_path(sprite.stylesheet_path)
          p "Sprite Stylesheet Path: #{sprite_stylesheet_path}" if debug
        end
      end

      private
        def context
          @context
        end

    end
  end
end
