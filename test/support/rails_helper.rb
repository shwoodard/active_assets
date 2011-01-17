require 'fileutils'

module RailsHelper
  def rails_root
    @rails_root = File.expand_path('../../fixtures/rails_root', __FILE__)
  end

  def delete_cached_assets
    Dir[File.join(rails_root, 'public/javascripts/cache'), File.join(rails_root, 'public/stylesheets/cache')].each do |dir|
      FileUtils.rm_rf(dir)
    end
  end
end
