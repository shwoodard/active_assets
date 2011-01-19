require 'active_support'

module ActiveAssets
  module ActiveSprites
    extend ActiveSupport::Autoload

    autoload :SpritePiece
    autoload :Sprite
    autoload :Sprites
  end
end