require 'active_assets'

module Rails
  module ActiveAssets
    def expansions(&blk)
      @expansions ||= ::ActiveAssets::Expansions.new
      @expansions.instance_eval(&blk) if block_given?
      @expansions
    end
  end
end
