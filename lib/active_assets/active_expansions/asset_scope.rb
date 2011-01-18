module ActiveAssets
  module ActiveExpansions
    module AssetScope
      def group(*groups, &blk)
        @current_groups = groups
        instance_eval(&blk)
      ensure
        @current_groups = nil
      end

      def js(&blk)
        current_type :js, &blk
      end

      def css(&blk)
        current_type :css, &blk
      end

      private
        def current_type(type, &blk)
          @current_type = type
          instance_eval(&blk)
        ensure
          @current_type = nil
        end

    end
  end
end
