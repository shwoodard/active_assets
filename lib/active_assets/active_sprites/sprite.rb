module ActiveAssets
  module ActiveSprites
    class Sprite
      REQUIRED_PROPS = [:path, :stylesheet_path, :orientation]

      class ValidationError < StandardError
        attr_reader :sprite, :missing_fields
        def initialize(sprite, missing_fields, msg = nil)
          @sprite, @missing_fields = sprite, missing_fields
          super(msg || "Your sprite#{", #{sprite.name}," if sprite.name} is invalid.  It is missing the following fields: #{missing_fields.join(', ')}")
        end
      end

      class OrientationInvalid < ValidationError
        def initialize(sprite, orientation)
          super(sprite, [:orientation], "The sprite orientation, #{orientation}, is invalid")
        end
      end

      attr_reader :path, :stylesheet_path, :name, :orientation

      def initialize
        @sprite_pieces = Hash.new do |sprite_pieces, path|
          raise SpritePiece::ValidationError.new(nil, [:path]) if path.blank?
          sprite_pieces[path] = SpritePiece.new
        end
      end

      def has_sprite_piece_with_path?(path)
        @sprite_pieces.has_key?(path)
      end

      def [](path)
        return nil unless @sprite_pieces.has_key?(path)
        @sprite_pieces[path]
      end

      def paths
        @sprite_pieces.keys
      end

      def configure(sprite_path, stylesheet_path, options = {}, &blk)
        @path ||= sprite_path
        @name = options.delete(:as) || sprite_path
        @stylesheet_path = stylesheet_path
        @orientation = options[:orientation] || :vertical
        valid!
        instance_eval(&blk) if block_given?
        self
      end

      def sprite_piece(options, &blk)
        path, css_selector = SpritePiece::Mapping.find_mapping(options)
        options.delete(path)
        mapping = SpritePiece::Mapping.new(path, css_selector)
        @sprite_pieces[path].configure(mapping, options, &blk)
      end
      alias_method :sp, :sprite_piece
      alias_method :_, :sprite_piece

      def validation_error
        missing_fields = REQUIRED_PROPS.reject {|prop| send(prop).present?}
        return OrientationInvalid.new(self, orientation) if orientation && ![:vertical, :horizontal].include?(orientation.to_sym)
        return if missing_fields.empty?
        ValidationError.new(self, missing_fields)
      end

      def valid?
        !validation_error
      end

      def valid!
        e = validation_error
        raise e if e
      end

      private

        def orientation=(orientation)
          @orientation = orientation
        end
    end
  end
end
