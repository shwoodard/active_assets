module ActiveAssets
  module ActiveExpansions
    module TypeInferrable
      def inferred_type(file_path, allowed_extensions = Asset::VALID_TYPES)
        file_ext = File.extname(file_path)
        return [nil, nil] unless file_ext.present? && (3..5).include?(file_ext.size)
        file_ext = file_ext[1..-1].to_sym
        [allowed_extensions.include?(file_ext) && file_ext, file_ext]
      end
    end
  end
end
