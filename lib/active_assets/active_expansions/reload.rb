module ActiveAssets
  module ActiveExpansions
    module Reload

      def self.extended(controller)
        controller.before_filter do
          ActiveAssets::ActiveExpansions.remove_active_expansions
          ActiveAssets::ActiveExpansions.load_expansions_and_register
        end
      end

    end
  end
end