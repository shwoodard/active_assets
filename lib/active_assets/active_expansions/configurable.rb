require 'active_support/concern'

module ActiveAssets
  module ActiveExpansions
    module Configurable
      extend ActiveSupport::Concern

      included do
        config_accessor :precache_assets, :reload_expansions
        self.precache_assets = false if precache_assets.nil?
        self.reload_expansions = false if reload_expansions.nil?
      end
    end
  end
end
