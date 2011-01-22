require 'helper'

class SpriteTest < Test::Unit::TestCase
  def setup
    Rails.application.sprites.clear
    initialize_application_or_load_sprites!
  end

  def teardown
    Rails.application.sprites.clear
  end

  def sprites
    Rails.application.sprites
  end

  def test_underscore_method
    assert_nothing_raised do
      Rails.application.sprites do
        sprite :foo do
          _"sprite_images/foo/1.png" => '.my_klass'
        end
      end
    end
  end

  def test_underscore_method_actually_adds_the_sp
    Rails.application.sprites do
      sprite :bar, :orientation => :horizontal do
        _"sprite_images/foo/1.png" => '.my_klass'
      end
    end

    path = "sprite_images/foo/1.png"
    assert sprites[:bar].has_sprite_piece_with_path?(path)
    assert_equal '.my_klass', sprites[:bar][path].css_selector
  end

  def test_sprite_validation
    assert_raises ActiveAssets::ActiveSprites::Sprite::ValidationError do
      Rails.application.sprites do
        sprite ''
      end
    end
  end

  def test_raises_invalid_orientation
    assert_raises ActiveAssets::ActiveSprites::Sprite::OrientationInvalid do
      Rails.application.sprites do
        sprite :bar, :orientation => :bad
      end
    end
  end
end
