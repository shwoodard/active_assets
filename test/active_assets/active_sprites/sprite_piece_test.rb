require 'helper'

class SpritePiecetest < Test::Unit::TestCase
  def setup
    initialize_application_or_load_assets!
  end

  def teardown
    Rails.application.sprites.clear
  end

  def test_configure_with_block
    Rails.application.sprites do
      sprite :sprite1 do
        _"sprite_images/sprite1/1.png" => ".klass_1" do
          x 'right'
          y 'top'
          width '320px'
          height '240px'
        end
      end
    end

    assert_equal "240px", sprites[:sprite1]["sprite_images/sprite1/1.png"].height
    assert_equal "320px", sprites[:sprite1]["sprite_images/sprite1/1.png"].width
    assert_equal "top", sprites[:sprite1]["sprite_images/sprite1/1.png"].y
    assert_equal 'right', sprites[:sprite1]["sprite_images/sprite1/1.png"].x
  end

  def test_configure_with_options
    Rails.application.sprites do
      sprite :sprite2 do
        _"sprite_images/sprite1/1.png" => ".klass_1", :x => 'right', :y => 'top', :width => '320px', :height => '240px'
        _"sprite_images/sprite1/2.png" => ".klass_2"
      end
    end

    assert_equal '.klass_2', sprites[:sprite2]["sprite_images/sprite1/2.png"].css_selector
    assert_equal '.klass_1', sprites[:sprite2]["sprite_images/sprite1/1.png"].css_selector
    assert_equal "240px", sprites[:sprite2]["sprite_images/sprite1/1.png"].height
    assert_equal "320px", sprites[:sprite2]["sprite_images/sprite1/1.png"].width
    assert_equal "top", sprites[:sprite2]["sprite_images/sprite1/1.png"].y
    assert_equal 'right', sprites[:sprite2]["sprite_images/sprite1/1.png"].x
  end
end
