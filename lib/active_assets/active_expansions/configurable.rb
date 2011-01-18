require 'active_support/concern'

module ActiveAssets
  module ActiveExpansions
    module Configurable
      extend ActiveSupport::Concern

      included do
        config_accessor :precache_assets
        self.precache_assets = false if precache_assets.nil?
      end
    end
  end
end
