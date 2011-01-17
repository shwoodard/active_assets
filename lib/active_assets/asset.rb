module ActiveAssets
  class Asset < Struct.new(:path, :type, :expansion_name, :group, :cache)

    REQUIRED_PROPS = [:path, :type, :expansion_name]

    class InvalidContext < StandardError
      def initialize(msg = nil)
        msg ||= "You do not have a valid context to create this asset.  Some properties are missing.  They are: #{REQUIRED_PROPS.join(', ')}"
        super(msg)
      end
    end

    class ValidationError < InvalidContext
      attr_reader :asset, :missing_fields
      def initialize(asset, missing_fields)
        @asset, @missing_fields = asset, missing_fields
        super("#{asset} is not valid.  The following fields are missing, #{missing_fields.join(', ')}.")
      end
    end

    def initialize(*)
      super
      self.group ||= :all
      self.cache = self.cache == false ? false : true
    end

    def validation_error
      missing_fields = REQUIRED_PROPS.reject { |meth| send(meth) }
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

  end
end