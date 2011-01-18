require "rails"
require "rails/active_assets"
require 'active_support/ordered_options'

module ActiveAssets
  module ActiveExpansions
    class Railtie < Rails::Railtie
      rake_tasks do
        Dir[File.expand_path("../../../tasks/*.rake", __FILE__)].each {|f| load f}
      end

      config.active_expansions = ActiveSupport::OrderedOptions.new

      initializer :active_assets_extend_application do
        Rails.application.extend(Rails::ActiveAssets)
      end

      initializer :load_active_assets do
        load_active_assets(Rails.root)
        Rails.application.railties.engines.each {|e| load_active_assets(e.root) }
      end

      initializer :register_active_assets_expansions do
        Rails.application.expansions.javascripts.register! and Rails.application.expansions.stylesheets.register!
      end

      initializer :set_active_expansion_configs do
        options = config.active_expansions
        ActiveSupport.on_load(:active_expansions) do
          options.each { |k,v| send("#{k}=", v) }
        end
      end

      initializer :cache_active_assets do
        if Expansions.precache_assets
          Rails.application.expansions.javascripts.cache! and Rails.application.expansions.stylesheets.cache!
        end
      end

      private
        def load_active_assets(root)
          if File.exists?(File.join(root, 'config/assets.rb'))
            load File.join(root, 'config/assets.rb')
          elsif File.directory?(File.join(root, 'config/assets'))
            Dir[File.join(root, 'config/assets/*.rb')].each do |f|
              load f
            end
          end
        end
    end
  end
end
