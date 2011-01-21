require 'rack/mount'
require 'action_view'
require 'rmagick'
require 'fileutils'

module ActiveAssets
  module ActiveSprites
    class Runner
      class AssetContext < ActionView::Base
      end
      SpriteDetails = Struct.new(:sprite_path, :x, :y, :width, :height)
      
      include Magick

      DEFAULT_SPRITE = Image.new(0,0).freeze

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
          sprite_path = strip_asset_path(context.image_path(sprite.path))
          p "Sprite Path: #{sprite_path}" if debug
          sprite_stylesheet_path = strip_asset_path(context.stylesheet_path(sprite.stylesheet_path))
          p "Sprite Stylesheet Path: #{sprite_stylesheet_path}" if debug

          orientation = sprite.orientation.to_s
          sprite_pieces = sprite.sprite_pieces

          begin
            sprite_piece_paths = sprite_pieces.map do |sp|
              File.join(Rails.application.config.paths.public.to_a.first, strip_asset_path(context.image_path(sp.path)))
            end
            image_list = ImageList.new(*sprite_piece_paths)

            offset = 0

            image_list.each_with_index do |image, i|
              sprite_pieces[i].details = SpriteDetails.new(
                sprite_path,
                orientation == Sprite::Orientation::VERTICAL ? 0 : "#{-offset}px",
                orientation == Sprite::Orientation::VERTICAL ? "#{-offset}px" : 0,
                "#{image.columns}px",
                "#{image.rows}px"
              )
              offset += orientation == Sprite::Orientation::VERTICAL ? image.rows : image.columns
            end

            @sprite = image_list.montage do
              self.tile = orientation == Sprite::Orientation::VERTICAL ? "1x#{sprite_pieces.size}" : "#{sprite_pieces.size}x1"
              self.geometry = "+0+0"
              self.background_color = 'transparent'
            end

            stylesheet = SpriteStylesheet.new(sprite_path, sprite_pieces)
            stylesheet.write File.join(Rails.application.config.paths.public.to_a.first, sprite_stylesheet_path)
            write File.join(Rails.application.config.paths.public.to_a.first, sprite_path)
          rescue
            raise
          ensure
            finish
            @sprite_details = nil
          end
        end
      end

      private
        def context
          @context
        end

        def write(path)
          FileUtils.mkdir_p(File.dirname(path))
          @sprite.write("png:#{path}")
        end

        def finish
          @sprite.destroy! unless @sprite == DEFAULT_SPRITE
          @sprite = DEFAULT_SPRITE
        end

        def strip_asset_path(path)
          path.split('?').first
        end

    end
  end
end
