require 'helper'
require 'securerandom'

class AssetTest < Test::Unit::TestCase
  def setup
  end

  def teardown
  end

  def test_fields_are_set_to_defaults
    asset = ActiveAssets::ActiveExpansions::Asset.new
    assert_equal [nil, nil, nil, :all, true], ActiveAssets::ActiveExpansions::Asset.members.map {|member| asset.send(member)}
  end

  def test_can_set_fields_through_constructor
    asset = ActiveAssets::ActiveExpansions::Asset.new('/path/to/asset', :js, :defaults, [:development, :test], false)
    assert_equal ['/path/to/asset', :js, :defaults, [:development, :test], false], ActiveAssets::ActiveExpansions::Asset.members.map {|member| asset.send(member)}
  end

  def test_that_cache_will_be_true_unless_set_to_false
    asset = ActiveAssets::ActiveExpansions::Asset.new('/path/to/asset', :js, :defaults, [:development, :test], "not false")
    assert asset.cache
  end

  def test_validation
    asset = ActiveAssets::ActiveExpansions::Asset.new(nil, :js, :defaults, [:development, :test], "not false")
    assert !asset.valid?

    asset = ActiveAssets::ActiveExpansions::Asset.new('/path/to/asset', nil, :defaults, [:development, :test], "not false")
    assert !asset.valid?

    asset = ActiveAssets::ActiveExpansions::Asset.new('/path/to/asset', :js, nil, [:development, :test], "not false")
    assert !asset.valid?
  end

  def test_valid_bang
    asset = ActiveAssets::ActiveExpansions::Asset.new(nil, :js, :defaults, [:development, :test], "not false")
    assert_raise(ActiveAssets::ActiveExpansions::Asset::ValidationError) { asset.valid! }
  end

  def test_invalid_type
    asset = ActiveAssets::ActiveExpansions::Asset.new('/path/to/asset', :pdf, :defaults, [:development, :test], false)
    assert_raises(ActiveAssets::ActiveExpansions::Asset::InvalidAssetType) { asset.valid! }
  end

  ActiveAssets::ActiveExpansions::Asset.members.each do |member|
    eval <<-EOS
      def test_#{member}_equals
        val = SecureRandom.hex
        asset = ActiveAssets::ActiveExpansions::Asset.new('/path/to/asset', :js, :defaults, [:development, :test], false)
        asset.#{member}= val
        assert_equal val, asset.#{member}
      end
    EOS
  end
end
