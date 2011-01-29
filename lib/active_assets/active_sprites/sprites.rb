require 'active_support/configurable'

module ActiveAssets
  module ActiveSprites
    class Sprites
      include ActiveSupport::Configurable
      include Configurable
      ActiveSupport.run_load_hooks(:active_sprites, self)

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
          (args << options).tap {|a| a.last.delete(a.first)}
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

      def generate!(railtie = Rails.application)
        begin
          case sprite_backend
          when :rmagick
            require 'rmagick'
            RmagickRunner.new(railtie, @sprites).generate!
          when :mini_magick
            require 'mini_magick'
            MiniMagickRunner.new(railtie, @sprites).generate!
          when :chunky_png, :oily_png
            begin
              require 'oily_png'
              ChunkyPngRunner.new(railtie, @sprites).generate!
            rescue LoadError
              require 'chunky_png'
              ChunkyPngRunner.new(railtie @sprites).generate!
            end
          else
            begin
              require 'rmagick'
              RmagickRunner.new(railtie, @sprites).generate!
            rescue LoadError
              begin
                begin
                  require 'oily_png'
                  ChunkyPngRunner.new(railtie, @sprites).generate!
                rescue LoadError
                  require 'chunky_png'
                  ChunkyPngRunner.new(railtie, @sprites).generate!
                end
              rescue LoadError
                require 'mini_magick'
                MiniMagickRunner.new(railtie, @sprites).generate!
              end
            end
          end
        rescue LoadError => e
          msg = ''
          msg << "You have not specified any sprite runtime in your configuration.  We tried to load all supported runtimes, but failed to load any." if !sprite_backend
          msg << "Your requested backend, #{sprite_backend}, was not found." if sprite_backend
          msg << " Supported sprite backends include :rmagick, :chunky_png, and :mini_magick.  To use oily_png, install oily_png and configure with :chunky_png.\n"
          $stdout << msg
        end
      end
    end
  end
end
