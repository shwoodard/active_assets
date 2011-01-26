require 'active_support/concern'

module ActiveAssets
  module ActiveSprites
    module Configurable
      extend ActiveSupport::Concern

      included do
        config_accessor :sprite_backend
        self.sprite_backend = :rmagick if sprite_backend.nil?
      end
    end
  end
end
