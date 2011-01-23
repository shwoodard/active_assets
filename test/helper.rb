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

TEST_RAILS_ROOT = File.expand_path('../fixtures/rails_root', __FILE__)
TEST_SINATRA_ROOT = File.expand_path('../fixtures/sinatra_root', __FILE__)

Dir[File.expand_path('../support/**/*.rb', __FILE__)].each {|f| load f }

load File.join(TEST_RAILS_ROOT, 'config/application.rb')
load File.join(TEST_SINATRA_ROOT, 'active_assets_test_app.rb')

Capybara.configure do |capybara|
  capybara.app = ActiveAssetsTestApp
  capybara.default_driver = :culerity
  capybara.default_selector = :css
end

def is_port_open?(ip, port)
  begin
    Timeout::timeout(1) do
      begin
        s = TCPSocket.new(ip, port)
        s.close
        return true
      rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH
        return false
      end
    end
  rescue Timeout::Error
  end

  return false
end

if is_port_open?('127.0.0.1', '2113')
  Culerity.jruby_invocation = "#{File.expand_path('../../vendor/bin/ng', __FILE__)} org.jruby.Main"
else
  Culerity.jruby_invocation = "java -Xms32m -Xmx1024m -jar #{File.expand_path('../../vendor/jruby-complete-1.5.6.jar', __FILE__)}"
end


class Test::Unit::TestCase
  include RailsHelper
  include Capybara

  def sprites
    Rails.application.sprites
  end

  def tear_down_assets
    Rails.application.sprites.clear
    Rails.application.expansions.clear
  end
end
