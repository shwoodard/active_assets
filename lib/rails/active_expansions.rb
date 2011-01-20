require 'active_assets/active_expansions'

module Rails
  module ActiveExpansions
    def expansions(&blk)
      @expansions ||= ::ActiveAssets::ActiveExpansions::Expansions.new
      @expansions.instance_eval(&blk) if block_given?
      @expansions
    end
  end
end
