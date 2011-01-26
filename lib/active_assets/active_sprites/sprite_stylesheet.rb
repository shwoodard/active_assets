require 'fileutils'

module ActiveAssets
  module ActiveSprites
    class SpriteStylesheet
      def initialize(sprite_pieces)
        @sprite_pieces = sprite_pieces
      end

      def write(path)
        to_s!
        FileUtils.mkdir_p(File.dirname(path))
        File.open(path, 'w+') do |f|
          f.write @as_string
        end
      end

      private
        def to_s!
          @as_string ||= @sprite_pieces.map(&:to_s).join("\n")
        end
    end
  end
end
