require 'action_controller'
require 'action_view'
require 'rack/mount'
require 'action_view'
require 'fileutils'

module ActiveAssets
  module ActiveSprites
    class AbstractRunner
      class AssetContext < ActionView::Base
      end

      def initialize(railtie, sprites)
        @railtie = railtie
        setup_context
        @sprites = if ENV['SPRITE']
          sprites.select do |name, sprite|
            ENV['SPRITE'].split(',').map(&:strip).any? do |sp|
              # were going to be very forgiving
              name == sp ||
              name == sp.to_sym ||
              name == ::Rack::Mount::Utils.normalize_path(sp)
            end
          end.map(&:last)
        else
          sprites.values
        end
      end

      def generate!(debug = ENV['DEBUG'])
        @sprites.each do |sprite|
          next if sprite.sprite_pieces.empty?
          sprite_path = sanitize_asset_path(context.image_path(sprite.path))
          p "Sprite Path: #{sprite_path}" if debug
          sprite_stylesheet_path = sanitize_asset_path(context.stylesheet_path(sprite.stylesheet_path))
          p "Sprite Stylesheet Path: #{sprite_stylesheet_path}" if debug

          orientation = sprite.orientation.to_s
          sprite_pieces = sprite.sprite_pieces

          begin
            image_list, width, height = set_sprite_details_and_return_image_list(sprite, sprite_path, sprite_pieces, orientation)
            stylesheet = SpriteStylesheet.new(sprite_pieces)
            stylesheet.write File.join(@railtie.config.paths.public.to_a.first, sprite_stylesheet_path)
            create_sprite(sprite, sprite_path, sprite_pieces, image_list, width, height, orientation)
            write File.join(@railtie.config.paths.public.to_a.first, sprite_path), sprite.quality
          ensure
            finish
          end
        end
      end

      private
        def image_full_path(path)
          File.join(@railtie.config.paths.public.to_a.first, sanitize_asset_path(context.image_path(path)))
        end

        def context
          @context
        end

        def sanitize_asset_path(path)
          path.split('?').first
        end

        def setup_context
          unless @railtie.config.respond_to?(:action_controller)
            @railtie.config.action_controller = ActiveSupport::OrderedOptions.new

            paths   = @railtie.config.paths
            options = @railtie.config.action_controller

            options.assets_dir           ||= paths.public.to_a.first
            options.javascripts_dir      ||= paths.public.javascripts.to_a.first
            options.stylesheets_dir      ||= paths.public.stylesheets.to_a.first

            ActiveSupport.on_load(:action_controller) do
              options.each { |k,v| send("#{k}=", v) }
            end
          end

          controller = ActionController::Base.new
          @context = AssetContext.new(@railtie.config.action_controller, {}, controller)
        end

    end
  end
end
