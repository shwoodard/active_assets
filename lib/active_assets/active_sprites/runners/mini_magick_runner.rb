require 'mini_magick'

module ActiveAssets
  module ActiveSprites
    class MiniMagickRunner < AbstractRunner
      private
        def set_sprite_details_and_return_image_list(sprite, sprite_path, sprite_pieces, orientation)
          offset = 0

          image_list = sprite_pieces.map do |sp|
            sp_path = image_computed_full_path(sp.path)
            image = MiniMagick::Image.open(sp_path)
            sp.details = SpritePiece::Details.new(
              sprite_url(sprite, sprite_path),
              orientation == Sprite::Orientation::VERTICAL ? 0 : offset,
              orientation == Sprite::Orientation::VERTICAL ? offset : 0,
              image["width"],
              image["height"]
            )
            offset += orientation == Sprite::Orientation::VERTICAL ? image["width"] : image["height"]

            image
          end
          [image_list]
        end

        def create_sprite(sprite, sprite_path, sprite_pieces, image_list, width, height, orientation, verbose)
          begin
            tempfile = Tempfile.new(File.extname(sprite_path)[1..-1])
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
          image_list.size.times { $stdout << '.' } if verbose
          $stdout << "\n" if verbose
          @sprite = MiniMagick::Image.open(tempfile.path)
        end

        def write(path, quality = nil)
          FileUtils.mkdir_p(File.dirname(path))
          @sprite.write(path)
        end

        def finish
          @sprite.destroy! if @sprite
          @sprite = nil
        end

        def runner_name
          'mini_magick'
        end

    end
  end
end
