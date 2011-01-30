module ActiveAssets
  module ActiveSprites
    class SpritePiece
      class ValidationError < StandardError
        attr_reader :sprite_piece, :missing_fields
        def initialize(sprite_piece, missing_fields)
          @sprite, @missing_fields = sprite_piece, missing_fields
          super("#{"Your sprite piece could not be created.  " if @sprite_piece.nil?}  Your sprite piece is invalid. It is missing the following fields: #{@missing_fields.join(', ')}")
        end
      end

      class Mapping
        attr_reader :path, :css_selector

        def initialize(path, css_selector)
          raise ValidationError.new(nil, [:path]) if path.blank?
          @path, @css_selector = path, css_selector
        end
      end

      Details = Struct.new(:sprite_path, :x, :y, :width, :height)

      GEOMETRY_PROPS = [:x, :y, :width, :height]
      attr_reader(*GEOMETRY_PROPS)
      attr_accessor :details
      delegate :path, :css_selector, :to => :mapping

      def configure(mapping, options = {}, &blk)
        @mapping = mapping
        options.each {|k,v| send(k, v)}
        instance_eval(&blk) if block_given?
        self
      end

      def to_css
        return '' if details.nil?
        <<-CSS
#{css_selector}
{
  width:#{width || "#{details.width}px"};
  height:#{height || "#{details.height}px"};
  background:url('#{details.sprite_path}') no-repeat #{x || "#{-details.x}px"} #{y || "#{-details.y}px"};
  display:block;
}
        CSS
      end

      def to_background_position
        return '' if details.nil?
        <<-CSS
#{css_selector}
{
  background-position:#{x || "#{-details.x}px"} #{y || "#{-details.y}px"};
}
        CSS
      end

      def to_s
        "|\t#{path}\t|\t#{css_selector}\t|\t#{details.x}\t|\t#{details.y}\t|\t#{details.width}\t|\t#{details.height}\t|\n"
      end

      GEOMETRY_PROPS.each do |prop|
        eval <<-METH
          def #{prop}(*args)
            #{prop}, *_ = args
            @#{prop} = #{prop} if #{prop}
            @#{prop}
          end
        METH
      end

      private
        def mapping
          @mapping
        end

    end
  end
end