require 'active_assets'

module Rails
  module ActiveAssets
    def expansions(&blk)
      @expansions ||= ::ActiveAssets::ActiveExpansions::Expansions.new
      @expansions.instance_eval(&blk) if block_given?
      @expansions
    end

    def sprites(&blk)
      @sprites ||= ::ActiveAssets::ActiveSprites::Sprites.new
      @sprites.instance_eval(&blk) if block_given?
      @sprites
    end
  end
end
