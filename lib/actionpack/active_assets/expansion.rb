require 'active_support'
require 'active_support/hash_with_indifferent_access'

module ActiveAssets
  class Expansion
    attr_reader :type, :name, :assets, :namespace
    alias_method :all, :assets
    delegate :empty?, :to => :assets

    def initialize(name)
      @name = name
      @assets = []
    end

    def configure(options = {}, &blk)
      @type, @group, @namespace = options.values_at(:type, :group, :namespace)
      instance_eval(&blk) if block_given?
      self
    end

    def asset(path, options = {})
      options = HashWithIndifferentAccess.new(options)
      options.assert_valid_keys(*Asset.members)
      inferred_type = ['.js', '.css'].include?(File.extname(path)) && File.extname(path)[1..-1].to_sym
      options.reverse_merge!(:type => @current_type || type || inferred_type, :expansion_name => name, :group => @current_groups)
      options.merge!(:path => path)
      members = options.values_at(*Asset.members)
      a = Asset.new(*members)
      a.valid!
      @assets << a
    end
    alias_method :a, :asset
    alias_method :`, :asset

    def group(*groups, &blk)
      @current_groups = groups
      instance_eval(&blk)
    ensure
      @current_groups = nil
    end

    def namespace(&blk)
      raise NoMethodError, "Cannot call namespace from within expansion." if block_given?
      @namespace
    end
  end
end
