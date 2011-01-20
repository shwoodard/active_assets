require 'rails/active_expansions'
require 'rails/active_sprites'
require 'active_assets'

module Rails
  module ActiveAssets
    include ActiveExpansions
    include ActiveSprites
  end
end
