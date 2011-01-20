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

      def sprite(*args, &blk)
        sprite_path, stylesheet_path, options, as =
        case args.first
        when Hash
          options = args.shift
          args = *options.find {|k,v| k.is_a?(String) }
          (args << options).tap {|args| args.last.delete(args.first)}
        when Symbol
          # todo make default paths configurable
          ["sprites/#{args.first.to_s}.png", "sprites/#{args.first.to_s}.css", args.extract_options!, args.first]
        when String
          path = args.first
          [path, "#{File.dirname(path)}/#{File.basename(path, File.extname(path))}.css", args.extract_options!]
        end
        options.reverse_merge!(:as => as)
        @sprites[options[:as] || sprite_path].configure(sprite_path, stylesheet_path, options, &blk)
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
