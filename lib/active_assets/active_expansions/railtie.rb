require "rails"
require "rails/active_assets/active_expansions"
require 'active_support/ordered_options'

module ActiveAssets
  module ActiveExpansions
    class Railtie < Rails::Railtie
      rake_tasks do
        Dir[File.expand_path("../../../tasks/active_expansions/*.rake", __FILE__)].each {|f| load f}
      end

      config.active_expansions = ActiveSupport::OrderedOptions.new

      initializer 'active_expansion-extend-application' do
        Rails.application.extend(Rails::ActiveExpansions)
      end

      initializer 'active_expansions-load-definitons' do
        load_active_assets(Rails.root)
        Rails.application.railties.engines.each {|e| load_active_assets(e.root) }
      end

      initializer 'active_expansions-register' do
        Rails.application.expansions.javascripts.register!
        Rails.application.expansions.stylesheets.register!
      end

      initializer 'active_expansions-set-configs' do
        options = config.active_expansions
        ActiveSupport.on_load(:active_expansions) do
          options.each { |k,v| send("#{k}=", v) }
        end
      end

      initializer 'active_expansions-cache' do
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
