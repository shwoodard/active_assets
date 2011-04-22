require "rails"
require "rails/active_expansions"
require 'active_support/ordered_options'
require 'active_assets/active_expansions/reload'

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

      initializer 'active_expansions-set-configs' do
        options = config.active_expansions
        ActiveSupport.on_load(:active_expansions) do
          options.each { |k,v| send("#{k}=", v) }
        end
      end

      initializer 'active_expansions-load-definitions-and-register' do
        ActiveExpansions.load_expansions_and_register

        if ActiveAssets::ActiveExpansions::Expansions.reload_expansions
          ActionController::Base.extend(Reload)
        end
      end

      initializer 'active_expansions-cache' do
        if Expansions.precache_assets
          Rails.application.expansions.javascripts.cache!
          Rails.application.expansions.stylesheets.cache!
        end
      end
    end
  end
end
