require 'active_support'

module ActiveAssets
  extend ActiveSupport::Autoload

  autoload :Asset
  autoload :Expansion
  autoload :Assets
  autoload :Javascripts
  autoload :Stylesheets
  autoload :Expansions
end
