ENV['RAILS_ENV'] ||= 'test'
require 'test/unit'

require 'rails/all'
require 'active_assets'

TEST_RAILS_ROOT = File.expand_path('../fixtures/rails_root', __FILE__)

Dir[File.expand_path('../support/**/*.rb', __FILE__)].each {|f| load f }

load File.join(TEST_RAILS_ROOT, 'config/application.rb')

class Test::Unit::TestCase
  include RailsHelper
end
