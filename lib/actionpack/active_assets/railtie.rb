require "rails"
require "actionpack/active_assets"

module ActiveAssets
  class Railtie < Rails::Railtie
    initializer :extend_active_assets do
      Rails.application.extend(Module.new do
        def expansions(&blk)
          @expansions ||= Expansions.new
          @expansions.instance_eval(&blk) if block_given?
          @expansions
        end
      end)
    end

    initializer :load_active_assets do
      load_active_assets(Rails.root)
      Rails.application.railties.engines.each {|e| load_active_assets(e.root) }
    end

    initializer :register_active_assets_expansions do
      Rails.application.expansions.javascripts.register! and Rails.application.expansions.stylesheets.register!
    end

    initializer :cache_active_assets do
      if ActionController::Base.perform_caching
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
