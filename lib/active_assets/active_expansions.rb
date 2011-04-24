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

    def self.load_active_expansions(root)
      if File.exists?(File.join(root, 'config/assets.rb'))
        load File.join(root, 'config/assets.rb')
      elsif File.directory?(File.join(root, 'config/assets'))
        Dir[File.join(root, 'config/assets/*.rb')].each do |f|
          load f
        end
      end
    end

    def self.load_expansions_and_register
      ActiveExpansions.load_active_expansions(Rails.root)
      Rails.application.railties.engines.each {|e| ActiveExpansions.load_active_expansions(e.root) }
      Rails.application.expansions.javascripts.register!
      Rails.application.expansions.stylesheets.register!
    end

    def self.remove_active_expansions
      Rails.application.expansions.javascripts.expansion_names.each do |expansion|
        Rails.application.expansions.javascripts.remove(expansion)
        if ActionView::Helpers::AssetTagHelper.javascript_expansions.has_key?(expansion)
          ActionView::Helpers::AssetTagHelper.javascript_expansions.delete(expansion)
        end
      end

      Rails.application.expansions.stylesheets.expansion_names.each do |expansion|
        Rails.application.expansions.stylesheets.remove(expansion)
        if ActionView::Helpers::AssetTagHelper.stylesheet_expansions.has_key?(expansion)
          ActionView::Helpers::AssetTagHelper.stylesheet_expansions.delete(expansion)
        end
      end
    end
  end
end
