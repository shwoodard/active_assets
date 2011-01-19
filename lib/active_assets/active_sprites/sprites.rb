module ActiveAssets
  module ActiveSprites
    class Sprites
      def initialize
        @sprites = Hash.new do |sprites, name|
          sprites[name] = Sprite.new
        end
      end

      def describe(&blk)
        instance_eval(&blk) if block_given?
        self
      end

      def all
        @sprites.values
      end

      def sprite(name_or_path, options = {}, &blk)
        sprites_key = @sprites.has_key?(name_or_path) ? name_or_path : (options[:as] || name_or_path)
        @sprites[sprites_key].configure(name_or_path, options, &blk)
      end

      def [](name)
        return nil unless @sprites.has_key?(name)
        @sprites[name]
      end

      def clear
        @sprites.clear
      end
    end
  end
end
