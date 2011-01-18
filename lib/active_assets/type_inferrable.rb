module ActiveAssets
  module TypeInferrable
    def inferred_type(file_path, allowed_extensions = %w{js css})
      if allowed_extensions.include?(file_type = File.extname(file_path)[1..-1])
        file_type.to_sym
      end
    end
  end
end
