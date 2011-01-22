require 'helper'

class RunnerTest < Test::Unit::TestCase

  def setup
    initialize_application_or_load_sprites!

    assert_false Rails.application.sprites.all.empty?

    assert_nothing_raised do
      Rails.application.sprites.generate!
    end
  end

  def teardown
    FileUtils.rm_rf(Rails.root.join('public/images/sprites'))
    FileUtils.rm_rf(Rails.root.join('public/stylesheets/sprites'))

    tear_down_assets
  end

  def test_sprite_exists
    assert File.exists?(Rails.root.join('public/images/sprites/3.png'))
    assert File.exists?(Rails.root.join('public/images/sprites/4.png'))
  end
  
  def test_stylesheets_exists
    assert File.exists?(Rails.root.join('public/stylesheets/sprites/3.css'))
    assert File.exists?(Rails.root.join('public/stylesheets/sprites/4.css'))
  end
end
