class ActiveAssetsGenerator < Rails::Generator::Base
  def manifest
    record do |m|
      m.file 'active_assets.rb', 'config/initializers/active_assets.rb'
      m.file 'active_assets.rake', 'lib/tasks/active_assets.rake'
    end
  end
end
