module ActiveAssets
  module ActiveSprites
    class SpritePiece
      class Mapping
        attr_reader :path, :css_selector
        def initialize(mapping)
          @path, @css_selector = mapping.keys.first, mapping[mapping.keys.first]
        end
      end

      delegate :path, :css_selector, :to => :mapping

      def initialize(mapping)
        @mapping = mapping
      end

      def configure(options = {}, &blk)
      end

      private
        def mapping
          @mapping
        end
    end
  end
end