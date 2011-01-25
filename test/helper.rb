ENV['RAILS_ENV'] ||= 'test'

require 'rubygems'
require 'test/unit'
require 'capybara'
require 'capybara/dsl'
require 'culerity'

require 'rails/all'
require 'active_assets'

require 'socket'
require 'timeout'

require 'raster_graphics'

TEST_RAILS_ROOT = File.expand_path('../fixtures/rails_root', __FILE__)

Dir[File.expand_path('../support/**/*.rb', __FILE__)].each {|f| load f }

load File.join(TEST_RAILS_ROOT, 'config/application.rb')

class Test::Unit::TestCase
  include RailsHelper

  include(Module.new do
    def percent_difference(image_1_path, image_2_path)
      Pixmap.open(image_1_path) - Pixmap.open(image_2_path)
    end
  end)

  def sprites
    Rails.application.sprites
  end

  def tear_down_assets
    Rails.application.sprites.clear
    Rails.application.expansions.clear
  end
end
