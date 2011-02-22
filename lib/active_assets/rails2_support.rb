gem 'rails', '< 3.0.0.beta' # Prevent mistakes loading this against rails 3

require 'initializer'
require 'active_support/ordered_hash'
require 'active_support/ordered_options'

module Rails

  class Application
    def config
      Rails.configuration
    end unless methods.grep(/^config$/).any? # Use grep + regexp for 1.8 + 1.9
  end

  class << self
    alias config configuration unless respond_to?(:config)
  end

  def self.application
    @application ||= Application.new
  end

  class Configuration
    def active_expansions
      @active_expansions ||= ActiveSupport::OrderedOptions.new
    end

    def active_sprites
      @active_sprites ||= ActiveSupport::OrderedOptions.new
    end
  end
end