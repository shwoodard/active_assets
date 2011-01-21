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
    load_sprites! if Rails.application && Rails.application.instance_variable_defined?(:@ran)
    initialize_application! unless Rails.application && Rails.application.instance_variable_defined?(:@ran)
  end

  def initialize_application_or_load_expansions!
    load_assets! if Rails.application && Rails.application.instance_variable_defined?(:@ran)
    initialize_application! unless Rails.application && Rails.application.instance_variable_defined?(:@ran)
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
    ActiveAssetsTest::Application.initialize!
  end
end
