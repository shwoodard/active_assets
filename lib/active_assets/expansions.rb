module ActiveAssets
  class Expansions

    def initialize
      @expansions = Hash.new do |expansions, type|
        expansions[type] = Hash.new { |typed_exps, name| typed_exps[name] = Expansion.new(name) }
      end
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
      options = HashWithIndifferentAccess.new(options)
      inferred_type = ['.js', '.css'].include?(File.extname(path)) && File.extname(path)[1..-1].to_sym
      current_expansion_name, current_expansion_options = @current_expansion_config
      options.reverse_merge!(:type => @current_type || inferred_type, :expansion_name => current_expansion_name, :group => @current_groups)
      raise Asset::InvalidContext unless options[:type] && options[:expansion_name]

      expansion_options = {:type => options[:type]}.reverse_merge(current_expansion_options || {})
      begin
        @expansions[options[:type]][options[:expansion_name]].configure(expansion_options).asset(path, options)
      rescue Asset::InvalidContext
        @expansions[options[:type]].delete(options[:expansion_name]) if @expansions[options[:type]][options[:expansion_name]].empty?
        raise
      end
    end
    alias_method :a, :asset
    alias_method :`, :asset

    def expansion(name, options = {}, &blk)
      options.update(:type => @current_type) if @current_type
      options.update(:namespace => @current_namespace) if @current_namespace
      current_expansion_config(name, options, &blk) unless options[:type]
      @expansions[options[:type]][name].configure(options, &blk) if options[:type]
    end

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
      def current_expansion_config(name, options, &blk)
        @current_expansion_config = [name, options]
        instance_eval(&blk)
      ensure
        @current_expansion_config = nil
      end

      def current_type(type, &blk)
        @current_type = type
        instance_eval(&blk)
      ensure
        @current_type = nil
      end

  end
end
