module ActiveAssets
  class Expansions
    include AssetsScope
    include TypeInferrable

    def initialize
      @expansions = Hash.new(&method(:build_expansions_hash_with_defaults))
    end

    def register(&blk)
      instance_eval(&blk) if block_given?
      self
    end

    def namespace(name, &blk)
      @current_namespace = name
      instance_eval(&blk)
    ensure
      @current_namespace = nil
    end

    def asset(path, options = {})
      deferred_expansion_name, deferred_expansion_options = @deferred_expansion_config
      inferred_type, extension = inferred_type(path)

      options = HashWithIndifferentAccess.new(options).reverse_merge(
        :type => inferred_type || @current_type,
        :expansion_name => deferred_expansion_name,
        :group => @current_groups
      )

      expansion_options = update_expansion_options(deferred_expansion_options || {}, options[:type])

      # asset call below is executed in the scope of the ActiveAssets::Expansion
      @expansions[options[:type] || extension][options[:expansion_name]].configure(expansion_options) do
        asset(path, options)
      end
    end
    alias_method :a, :asset
    alias_method :`, :asset

    def expansion(name, options = {}, &blk)
      options = update_expansion_options(options)

      if options[:type].present?
        @expansions[options[:type]][name].configure(options, &blk)
      else
        defer_expansion(name, options, &blk)
      end
    end

    def javascripts
      Javascripts.new(@expansions[:js])
    end

    def stylesheets
      Stylesheets.new(@expansions[:css])
    end

    def all
      @expansions[:js].values + @expansions[:css].values
    end

    def clear
      @expansions.clear
    end

    private
      def defer_expansion(name, options, &blk)
        @deferred_expansion_config = [name, options]
        instance_eval(&blk)
      ensure
        @deferred_expansion_config = nil
      end

      def build_expansions_hash_with_defaults(expansions, expansion_type)
        raise Asset::AmbiguousContext.new(:type) if expansion_type.blank?
        raise Asset::InvalidAssetType.new(expansion_type) unless Asset::VALID_TYPES.include?(expansion_type.to_sym)

        expansions[expansion_type.to_sym] = build_typed_expansion_hash_with_defaults
      end

      def build_typed_expansion_hash_with_defaults
        Hash.new do |typed_expansions, expansion_name|
          raise Asset::AmbiguousContext.new(:name) if expansion_name.blank?
          typed_expansions[expansion_name] = Expansion.new(expansion_name)
        end
      end

      def update_expansion_options(options, asset_type = nil)
        o = options.reverse_merge(:type => @current_ytpe, :namespace => @current_namespace)
        o.update(:type => asset_type) if asset_type
        o
      end
  end
end
