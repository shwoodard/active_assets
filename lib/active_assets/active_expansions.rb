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

    def self.define_tasks
      namespace :activeexpansions do
        desc "Cache the active expansions to the {stylesheets,javascripts} cache directory"
        task :cache => :environment do
          Rails.application.expansions.javascripts.cache! and Rails.application.expansions.stylesheets.cache!
        end
      end
    end
  end
end
