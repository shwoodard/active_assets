module ActiveAssets
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
          group_assets = expansion.assets.select {|a| Array(a.group).include?(:deploy) || Array(a.group).any? {|e| Rails.env.send(:"#{e}?") }}
          group_assets.map(&:path) + [File.join("cache#{"/#{expansion.namespace}" if expansion.namespace}", expansion.name.to_s)]
        else
          expansion.assets.select {|a| a.group == :all || Array(a.group).any? {|e| Rails.env.send(:"#{e}?") } }.map(&:path)
        end

        paths.map! {|path| File.join(File.dirname(path), File.basename(path, ".#{asset_type_short}")) }

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

        paths.map! {|path| File.join(File.dirname(path), File.basename(path, ".#{asset_type_short}")) }

        FileUtils.mkdir_p(File.dirname(file_path))
        File.open(file_path, 'w+') do |f|
          paths.each do |path|
            in_file = Rails.root.join('public', asset_type.pluralize, "#{path}.#{asset_type_short}")
            f.puts File.read(in_file)
          end
        end
      end
    end

    def asset_type_short
      asset_type == 'javascript' ? 'js' : 'css'
    end
  end
end
