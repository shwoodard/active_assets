require 'active_support/concern'

module ActiveAssets
  module ActiveSprites
    module Configurable
      extend ActiveSupport::Concern

      included do
        config_accessor :sprite_backend
      end
    end
  end
end
