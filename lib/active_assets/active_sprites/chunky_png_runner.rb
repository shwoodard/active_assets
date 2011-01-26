require 'action_controller'
require 'action_view'
require 'rack/mount'
require 'action_view'
require 'fileutils'
begin
  require 'oily_png'
rescue LoadError
  require 'chunky_png'
end

module ActiveAssets
  module ActiveSprites
    class ChunkyPngRunner
      class AssetContext < ActionView::Base
      end

      def initialize(sprites)
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

      def generate!(railtie = Rails.application, debug = ENV['DEBUG'])
        p "Engine Class Name:  #{railtie.class.name}" if debug

        context = setup_context(railtie)

        @sprites.each do |sprite|
          next if sprite.sprite_pieces.empty?
          sprite_path = sanitize_asset_path(context.image_path(sprite.path))
          p "Sprite Path: #{sprite_path}" if debug
          sprite_stylesheet_path = sanitize_asset_path(context.stylesheet_path(sprite.stylesheet_path))
          p "Sprite Stylesheet Path: #{sprite_stylesheet_path}" if debug

          orientation = sprite.orientation.to_s
          sprite_pieces = sprite.sprite_pieces

          begin
            width, height = 0, 0
            image_list = []

            sprite_pieces.each do |sp|
              sprite_piece_path = File.join(railtie.config.paths.public.to_a.first, sanitize_asset_path(context.image_path(sp.path)))
              sp_image =  ChunkyPNG::Image.from_file(sprite_piece_path)
              image_list << sp_image
              sp.details = SpritePiece::Details.new(
                sprite.url.present? ? sprite.url : sprite_path,
                orientation == Sprite::Orientation::VERTICAL ? 0 : width,
                orientation == Sprite::Orientation::VERTICAL ? height : 0,
                sp_image.width,
                sp_image.height
              )

              width = orientation == Sprite::Orientation::HORIZONTAL ? width + sp_image.width : [width, sp_image.width].max
              height = orientation == Sprite::Orientation::VERTICAL ? height + sp_image.height : [height, sp_image.height].max
            end

            @sprite = ChunkyPNG::Image.new(width, height, ChunkyPNG::Color::TRANSPARENT)

            image_list.each_with_index do |image, i|
              @sprite.replace(image, sprite_pieces[i].details.x, sprite_pieces[i].details.y)
            end

            stylesheet = SpriteStylesheet.new(sprite_pieces)
            stylesheet.write File.join(railtie.config.paths.public.to_a.first, sprite_stylesheet_path)
            write File.join(railtie.config.paths.public.to_a.first, sprite_path), sprite.quality
          ensure
            finish
          end
        end
      end

      private
        def write(path, quality = nil)
          FileUtils.mkdir_p(File.dirname(path))
          @sprite.save(path)
        end

        def finish
          @sprite = nil
        end

        def sanitize_asset_path(path)
          path.split('?').first
        end

        def setup_context(railtie)
          unless railtie.config.respond_to?(:action_controller)
            railtie.config.action_controller = ActiveSupport::OrderedOptions.new

            paths   = railtie.config.paths
            options = railtie.config.action_controller

            options.assets_dir           ||= paths.public.to_a.first
            options.javascripts_dir      ||= paths.public.javascripts.to_a.first
            options.stylesheets_dir      ||= paths.public.stylesheets.to_a.first

            ActiveSupport.on_load(:action_controller) do
              options.each { |k,v| send("#{k}=", v) }
            end
          end

          controller = ActionController::Base.new
          AssetContext.new(railtie.config.action_controller, {}, controller)
        end

    end
  end
end
