require 'helper'

class MiniMagickRunnerTest < Test::Unit::TestCase
  include AbstractRunnerTest

  def setup
    ActiveAssets::ActiveSprites::Sprites.sprite_backend = :mini_magick
    runner_setup
  end
end
