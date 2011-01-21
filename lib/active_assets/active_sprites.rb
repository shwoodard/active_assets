require 'active_support'

module ActiveAssets
  module ActiveSprites
    extend ActiveSupport::Autoload

    autoload :SpritePiece
    autoload :Sprite
    autoload :Sprites
    autoload :SpriteStylesheet
    autoload :Runner
  end
end