require 'active_assets/active_sprites'

module Rails
  module ActiveSprites
    def sprites(&blk)
      @sprites ||= ::ActiveAssets::ActiveSprites::Sprites.new
      @sprites.instance_eval(&blk) if block_given?
      @sprites
    end
  end
end
