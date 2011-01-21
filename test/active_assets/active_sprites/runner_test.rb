require 'helper'

class RunnerTest < Test::Unit::TestCase

  def setup
    initialize_application_or_load_assets!
  end

  def teardown
    FileUtils.rm_rf(Rails.root.join('public/images/sprites'))
    FileUtils.rm_rf(Rails.root.join('public/stylesheets/sprites'))
  end

  def test_generate
    assert_false Rails.application.sprites.all.empty?
  end

  def test_generate2
    assert_nothing_raised do
      Rails.application.sprites.generate!
    end
  end
end
