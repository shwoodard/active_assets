require 'active_support'

module ActiveAssets
  module ActiveExpansions
    extend ActiveSupport::Autoload

    autoload :Asset
    autoload :AssetScope
    autoload :TypeInferrable
    autoload :Configurable
    autoload :Expansion
    autoload :Assets
    autoload :Javascripts
    autoload :Stylesheets
    autoload :Expansions
  end
end
