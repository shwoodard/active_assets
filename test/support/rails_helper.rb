require 'fileutils'

module RailsHelper
  def rails_root
    @rails_root = TEST_RAILS_ROOT
  end

  def delete_cached_assets!
    Dir[File.join(rails_root, 'public/javascripts/cache'), File.join(rails_root, 'public/stylesheets/cache')].each do |dir|
      FileUtils.rm_rf(dir)
    end
  end

  def initialize_application_or_load_sprites!
    if Rails.application && initialized?
      load_sprites!
    elsif Rails.application && !initialized?
      initialize_application!
    end
  end

  def initialize_application_or_load_expansions!
    if Rails.application && (Rails.version.to_i < 3 || Rails.application.instance_variable_defined?(:@ran))
      load_assets!
    elsif !(Rails.application && Rails.application.instance_variable_defined?(:@ran))
      initialize_application!
    end
  end

  def load_assets!
    if File.exists?(File.join(rails_root, 'config/assets.rb'))
      load File.join(rails_root, 'config/assets.rb')
    elsif File.directory?(File.join(rails_root, 'config/assets'))
      Dir[File.join(rails_root, 'config/assets/*.rb')].each do |f|
        load f
      end
    end
  end

  def load_sprites!
    load File.join(rails_root, 'config/sprites.rb') if File.exists?(File.join(rails_root, 'config/sprites.rb'))
  end

  def initialize_application!
    if Rails.version.to_i >= 3
      ActiveAssetsTest::Application.initialize!
    end
  end

  def initialized?
    Rails.version.to_i < 3 || Rails.application.instance_variable_defined?(:@ran)
  end
end
