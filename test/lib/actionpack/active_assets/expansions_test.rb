require 'helper'

class AssetTest < Test::Unit::TestCase
  def setup
    ActiveAssetsTest::Application.initialize!
  end

  def teardown
    Rails.application.expansions.clear
  end

  def test_new
    assert_nothing_raised do
      ActiveAssets::Expansions.new
    end
  end

  def test_namespace
    Rails.application.expansions.namespace :fubar do
      expansion :foo, :type => :js do
        `bas/bar`
        `bar/bas`
      end
    end

    assert Rails.application.expansions.all.any? {|e| e.namespace == :fubar}
  end

  def test_namespace_2
    Rails.application.expansions do
      namespace :fubar do
        expansion :foo, :type => :js do
          `bas/bar`
          `bar/bas`
        end
      end
    end

    assert Rails.application.expansions.all.any? {|e| e.namespace == :fubar}
  end

  def test_namespace_3
    Rails.application.expansions do
      expansion :foo, :type => :js, :namespace => :fubar do
        `bas/bar`
        `bar/bas`
      end
    end

    assert Rails.application.expansions.all.any? {|e| e.namespace == :fubar}
  end

  def test_asset
    Rails.application.expansions.asset 'bas/bar', :type => :js, :expansion_name => :foo

    assert_equal :foo, Rails.application.expansions.javascripts.all.map {|e| e.assets}.flatten.find {|a| a.path == 'bas/bar'}.expansion_name
    assert Rails.application.expansions.javascripts.has_expansion?(:foo)
  end

  def test_asset_2
    Rails.application.expansions do
      expansion :foo do
        `bas/bar.js`
      end
    end

    assert_equal :foo, Rails.application.expansions.javascripts.all.map {|e| e.assets}.flatten.find {|a| a.path == 'bas/bar.js'}.expansion_name
    assert Rails.application.expansions.javascripts.has_expansion?(:foo)
  end

  def test_asset_3
    Rails.application.expansions do
      asset "bas/bar", :expansion_name => :foo, :type => :js
    end

    assert_equal :foo, Rails.application.expansions.javascripts.all.map {|e| e.assets}.flatten.find {|a| a.path == 'bas/bar'}.expansion_name
    assert Rails.application.expansions.javascripts.has_expansion?(:foo)
  end

  def test_asset_4
    Rails.application.expansions do
      asset "bas/bar.js", :expansion_name => :foo
    end

    assert_equal :foo, Rails.application.expansions.javascripts.all.map {|e| e.assets}.flatten.find {|a| a.path == 'bas/bar.js'}.expansion_name
    assert Rails.application.expansions.javascripts.has_expansion?(:foo)
  end

  def test_asset_5
    Rails.application.expansions do
      js do
        asset "bas/bar", :expansion_name => :foo
      end
    end

    assert_equal :foo, Rails.application.expansions.javascripts.all.map {|e| e.assets}.flatten.find {|a| a.path == 'bas/bar'}.expansion_name
    assert Rails.application.expansions.javascripts.has_expansion?(:foo)
  end

  def test_asset_6
    Rails.application.expansions do
      css do
        asset "bas/bar", :expansion_name => :foo
      end
    end

    assert_equal :foo, Rails.application.expansions.stylesheets.all.map {|e| e.assets}.flatten.find {|a| a.path == 'bas/bar'}.expansion_name
    assert Rails.application.expansions.stylesheets.has_expansion?(:foo)
  end

end
