require 'helper'

class ChunkyPngRunnerTest < Test::Unit::TestCase
  include AbstractRunnerTest

  def setup
    ActiveAssets::ActiveSprites::Sprites.sprite_backend = :chunky_png
    runner_setup
  end
end
