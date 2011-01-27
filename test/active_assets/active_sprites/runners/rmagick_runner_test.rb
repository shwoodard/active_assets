require 'helper'

class RmagickRunnerTest < Test::Unit::TestCase
  include AbstractRunnerTest

  def setup
    ActiveAssets::ActiveSprites::Sprites.sprite_backend = :rmagick
    runner_setup
  end
end
