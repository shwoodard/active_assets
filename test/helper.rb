ENV['RAILS_ENV'] ||= 'test'
require 'test/unit'

require 'rails/all'
require 'active_assets'

module TestActiveAssets; end

Dir[File.expand_path('../support/**/*.rb', __FILE__)].each {|f| load f }

include RailsHelper

load File.join(rails_root, 'config/application.rb')
