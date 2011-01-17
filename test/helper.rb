ENV['RAILS_ENV'] ||= 'test'
require 'test/unit'

require 'rails/all'
require 'active_assets'

Dir[File.expand_path('../support/**/*.rb', __FILE__)].each {|f| load f }
load File.expand_path('../fixtures/rails_root/config/application.rb', __FILE__)
