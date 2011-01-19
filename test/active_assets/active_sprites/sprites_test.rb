require 'helper'

class SpritesTest < Test::Unit::TestCase
  def setup
    initialize_application_or_load_assets!
  end

  def teardown
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
end
