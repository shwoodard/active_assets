require 'active_support'

module ActiveAssets
  extend ActiveSupport::Autoload

  autoload :Asset
  autoload :TypeScope
  autoload :TypeInferrable
  autoload :Expansion
  autoload :Assets
  autoload :Javascripts
  autoload :Stylesheets
  autoload :Expansions
end
