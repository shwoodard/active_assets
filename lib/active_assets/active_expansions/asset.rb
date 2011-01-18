module ActiveAssets
  module ActiveExpansions
    class Asset < Struct.new(:path, :type, :expansion_name, :group, :cache)

      REQUIRED_PROPS = [:path, :type, :expansion_name]
      VALID_TYPES = [:js, :css]

      class InvalidContext < StandardError
        def initialize(msg = nil)
          msg ||= "You do not have a valid context to create this asset.  Some properties are missing.  They are: #{REQUIRED_PROPS.join(', ')}."
          super(msg)
        end
      end

      class AmbiguousContext < InvalidContext
        def initilaize(missing_field)
          super("You do not have a valid context to create this asset.  Some properties are missing.  Our guess is your didn't specify a #{missing_field}")
        end
      end

      class ValidationError < InvalidContext
        attr_reader :asset, :missing_fields
        def initialize(asset, missing_fields)
          @asset, @missing_fields = asset, missing_fields
          super("#{asset} is not valid.  The following fields are missing, #{missing_fields.join(', ')}.")
        end
      end

      class InvalidAssetType < StandardError
        attr_reader :invalid_type
        def initilaize(invalid_type)
          @invalid_type = invalid_type
          super("#{invalid_type} is not a recognized asset type.")
        end
      end

      def initialize(*)
        super
        self.group ||= :all
        self.cache = self.cache == false ? false : true
      end

      def validation_error
        missing_fields = REQUIRED_PROPS.reject { |meth| send(meth) }
        if missing_fields.any?
          ValidationError.new(self, missing_fields)
        elsif !VALID_TYPES.include?(type)
          InvalidAssetType.new(type)
        end
      end

      def valid?
        !validation_error
      end

      def valid!
        e = validation_error
        raise e if e
      end

    end
  end
end
