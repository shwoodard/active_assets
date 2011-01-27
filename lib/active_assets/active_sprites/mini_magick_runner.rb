require 'action_controller'
require 'action_view'
require 'rack/mount'
require 'action_view'
require 'mini_magick'
require 'fileutils'

module ActiveAssets
  module ActiveSprites
    class MiniMagickRunner
      class ImageTempfile < Tempfile
        def make_tmpname(ext, n)
          'mini_magick%d-%d%s' % [$$, n, ext ? ".#{ext}" : '']
        end
      end

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
            sprite_piece_paths = sprite_pieces.map do |sp|
              File.join(railtie.config.paths.public.to_a.first, sanitize_asset_path(context.image_path(sp.path)))
            end
            
            image_list = sprite_piece_paths.map {|spp| MiniMagick::Image.open(spp) }

            offset = 0

            image_list.each_with_index do |image, i|
              sprite_pieces[i].details = SpritePiece::Details.new(
                sprite.url.present? ? sprite.url : sprite_path,
                orientation == Sprite::Orientation::VERTICAL ? 0 : offset,
                orientation == Sprite::Orientation::VERTICAL ? offset : 0,
                image["width"],
                image["height"]
              )
              offset += orientation == Sprite::Orientation::VERTICAL ? image["width"] : image["height"]
            end

            begin
              tempfile = ImageTempfile.new(File.extname(sprite_path)[1..-1])
              tempfile.binmode
            ensure
              tempfile.close
            end

            options = {
              :tile => orientation == Sprite::Orientation::VERTICAL ? "1x#{sprite_pieces.size}" : "#{sprite_pieces.size}x1",
              :geometry => "+0+0",
              :background => "transparent",
              :mattecolor => sprite.matte_color || '#bdbdbd'
            }

            args = options.map {|o, v| "-#{o} '#{v}'"}
            image_list.each {|img| args << img.path}
            args << tempfile.path

            MiniMagick::Image.new(image_list.first.path).run_command('montage', *args)
            @sprite = MiniMagick::Image.open(tempfile.path)

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
          @sprite.write(path)
        end

        def finish
          @sprite.destroy! if @sprite
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
