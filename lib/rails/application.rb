if Rails.version.to_i <= 2
  require 'active_support/ordered_options'
  require 'rails/active_assets'

  module Rails
    class Application
      # extend Rails::ActiveAssets

      def initialize
        Rails.configuration.instance_eval do
          def active_expansions
            @active_expansions ||= ActiveSupport::OrderedOptions.new
          end

          def active_sprites
            @active_sprites ||= ActiveSupport::OrderedOptions.new
          end
        end
      end

      def config
        Rails.configuration
      end
    end

    def self.application
      @@instance ||= Application.new
    end
  end
end
