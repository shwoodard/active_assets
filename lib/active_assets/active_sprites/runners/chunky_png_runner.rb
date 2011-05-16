begin
  require 'oily_png'
rescue LoadError
  require 'chunky_png'
end

module ActiveAssets
  module ActiveSprites
    class ChunkyPngRunner < AbstractRunner
      private
        def set_sprite_details_and_return_image_list(sprite, sprite_path, sprite_pieces, orientation)
          width, height = 0, 0

          image_list = sprite_pieces.map do |sp|
            sprite_piece_path = image_computed_full_path(sp.path)
            file_exists!(sprite_piece_path)
            sp_image =  ChunkyPNG::Image.from_file(sprite_piece_path)
            sp.details = SpritePiece::Details.new(
              sprite_url(sprite, sprite_path),
              orientation == Sprite::Orientation::VERTICAL ? 0 : width,
              orientation == Sprite::Orientation::VERTICAL ? height : 0,
              sp_image.width,
              sp_image.height
            )

            width = orientation == Sprite::Orientation::HORIZONTAL ? width + sp_image.width : [width, sp_image.width].max
            height = orientation == Sprite::Orientation::VERTICAL ? height + sp_image.height : [height, sp_image.height].max

            sp_image
          end
          [image_list, width, height]
        end

        def create_sprite(sprite, sprite_path, sprite_pieces, image_list, width, height, orientation, verbose)
          @sprite = ChunkyPNG::Image.new(width, height, ChunkyPNG::Color::TRANSPARENT)

          image_list.each_with_index do |image, i|
            @sprite.replace!(image, sprite_pieces[i].details.x, sprite_pieces[i].details.y)
            $stdout << '.' if verbose
          end
          $stdout << "\n" if verbose
        end

        def write(path, quality = nil)
          FileUtils.mkdir_p(File.dirname(path))
          @sprite.save(path)
        end

        def finish
          @sprite = nil
        end

        def runner_name
          begin
            require 'oily_png'
            'oily_png'
          rescue LoadError
            'chunky_png'
          end
        end
    end
  end
end
