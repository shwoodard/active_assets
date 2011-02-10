require 'rmagick'

module ActiveAssets
  module ActiveSprites
    class RmagickRunner < AbstractRunner
      include Magick

      DEFAULT_SPRITE = Image.new(0,0).freeze

      private
        def set_sprite_details_and_return_image_list(sprite, sprite_path, sprite_pieces, orientation)
          sprite_piece_paths = sprite_pieces.map do |sp|
            image_computed_full_path(sp.path)
          end
          image_list = ImageList.new(*sprite_piece_paths)

          offset = 0

          image_list.each_with_index do |image, i|
            sprite_pieces[i].details = SpritePiece::Details.new(
              sprite_url(sprite, sprite_path),
              orientation == Sprite::Orientation::VERTICAL ? 0 : offset,
              orientation == Sprite::Orientation::VERTICAL ? offset : 0,
              image.columns,
              image.rows
            )
            offset += orientation == Sprite::Orientation::VERTICAL ? image.rows : image.columns
          end

          [image_list]
        end

        def create_sprite(sprite, sprite_path, sprite_pieces, image_list, width, height, orientation, verbose)
          @sprite = image_list.montage do
            self.tile = orientation == Sprite::Orientation::VERTICAL ? "1x#{sprite_pieces.size}" : "#{sprite_pieces.size}x1"
            self.geometry = "+0+0"
            self.background_color = 'transparent'
            self.matte_color = sprite.matte_color || '#bdbdbd'
          end

          image_list.size.times { $stdout << '.' } if verbose
          $stdout << "\n" if verbose
        end

        def write(path, quality = nil)
          FileUtils.mkdir_p(File.dirname(path))
          @sprite.write("#{File.extname(path)[1..-1]}:#{path}") do
            self.quality = quality || 75
          end
        end

        def finish
          if @sprite
            @sprite.strip!
            @sprite.destroy! unless @sprite == DEFAULT_SPRITE
          end
          @sprite = DEFAULT_SPRITE
        end

        def runner_name
          'rmagick'
        end

    end
  end
end
