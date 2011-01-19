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

    assert_equal 'right', sprites[:sprite1]["sprite_images/sprite1/1.png"].x
  end

  def test_configure_with_options
    Rails.application.sprites do
      sprite :sprite2 do
        _"sprite_images/sprite1/1.png" => ".klass_1", :x => '0', :y => '320px'
        _"sprite_images/sprite1/2.png" => ".klass_2"
      end
    end

    assert_equal '0', sprites[:sprite2]["sprite_images/sprite1/1.png"].x
  end
end
