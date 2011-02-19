require 'active_support'

module ActiveAssets
  module ActiveExpansions
    autoload :Asset, 'active_assets/active_expansions/asset'
    autoload :AssetScope, 'active_assets/active_expansions/asset_scope'
    autoload :TypeInferrable, 'active_assets/active_expansions/type_inferrable'
    autoload :Configurable, 'active_assets/active_expansions/configurable'
    autoload :Expansion, 'active_assets/active_expansions/expansion'
    autoload :Assets, 'active_assets/active_expansions/assets'
    autoload :Javascripts, 'active_assets/active_expansions/javascripts'
    autoload :Stylesheets, 'active_assets/active_expansions/stylesheets'
    autoload :Expansions, 'active_assets/active_expansions/expansions'
  end
end
