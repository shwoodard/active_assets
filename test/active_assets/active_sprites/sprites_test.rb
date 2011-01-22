require 'helper'

class SpritesTest < Test::Unit::TestCase
  def setup
    Rails.application.sprites.clear
    initialize_application_or_load_sprites!
  end

  def teardown
    Rails.application.sprites.clear
  end

  def test_describe
    assert Rails.application.sprites.kind_of?(ActiveAssets::ActiveSprites::Sprites)
  end

  def test_all
    assert Rails.application.sprites.all.kind_of?(Array)
  end

  def test_sprite
    assert_nothing_raised do
       Rails.application.sprites do
         sprite :foo, :orientation => :vertical
       end
     end
  end

  def test_sprite_with_mapping
    Rails.application.sprites do
      sprite 'sprites/global.png' => 'sprites/global.css'
    end

    assert_equal 'sprites/global.css', Rails.application.sprites['sprites/global.png'].stylesheet_path
  end
end
