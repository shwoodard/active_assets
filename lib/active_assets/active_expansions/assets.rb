require 'fileutils'

module ActiveAssets
  module ActiveExpansions
    class Assets
      attr_reader :expansions

      def initialize(expansions)
        @expansions = expansions
      end

      def has_expansion?(name)
        @expansions.has_key?(name)
      end

      def expansion_names
        @expansion.keys
      end

      def [](expansion_name)
        @expansions[expansion_name]
      end

      def all(&blk)
        @expansions.values.each(&blk) if block_given?
        @expansions.values
      end

      def paths(expansion_name)
        self[expansion_name].assets.map(&:path)
      end

      def asset_type
        raise NoMethodError
      end

      def register!
        all do |expansion|
          paths = if ActionController::Base.perform_caching
            group_assets = expansion.assets.select do |a|
              Array(a.group).include?(:deploy) ||
              Array(a.group).any? {|e| e.to_s != 'all' && Rails.env.send(:"#{e}?") }
            end

            group_assets.map(&:path) + [File.join("cache#{"/#{expansion.namespace}" if expansion.namespace}", expansion.name.to_s)]
          else
            expansion.assets.select {|a| a.group == :all || Array(a.group).any? {|e| Rails.env.send(:"#{e}?") } }.map(&:path)
          end

          cleanse_paths!(paths)

          ActionView::Helpers::AssetTagHelper.send(:"register_#{asset_type}_expansion", expansion.name => paths)
        end
      end

      def cache!
        all do |expansion|
          file_path = "#{"#{expansion.namespace}/" if expansion.namespace}#{expansion.name}.#{asset_type_short}"
          file_path = Rails.root.join('public', asset_type.pluralize, 'cache', file_path)

          paths = expansion.assets.select {|a|
            a.cache &&
            (Array(a.group).include?(:all) ||
            Array(a.group).include?(:deploy) ||
            Array(a.group).any? {|e| Rails.env.send(:"#{e}?") })
          }.map(&:path)

          cleanse_paths!(paths)

          FileUtils.mkdir_p(File.dirname(file_path))

          File.open(file_path, 'w+') do |f|
            paths.each do |path|
              in_file = Rails.root.join('public', asset_type.pluralize, "#{path}.#{asset_type_short}")
              f.puts File.read(in_file)
            end
          end
        end
      end

      private
        def asset_type_short
          asset_type == 'javascript' ? 'js' : 'css'
        end

        def cleanse_paths!(paths)
          paths.map! do |path|
            if path =~ %r{://}
              path
            else
              dirname = File.dirname(path)
              basename = File.basename(path, ".#{asset_type_short}")
              dirname ==  '.' ? basename : File.join(dirname, basename)
            end
          end
        end
    end
  end
end
