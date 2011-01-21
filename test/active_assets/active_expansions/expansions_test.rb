require 'helper'

class ExpansionsTest < Test::Unit::TestCase
  def setup
    initialize_application_or_load_expansions!
  end

  def teardown
    delete_cached_assets!
    Rails.application.expansions.clear
  end

  def test_new
    assert_nothing_raised do
      ActiveAssets::ActiveExpansions::Expansions.new
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
  
    assert Rails.application.expansions.javascripts.has_expansion?(:foo)
    assert_equal :js, Rails.application.expansions.javascripts[:foo].type
    assert Rails.application.expansions.javascripts.all.map(&:assets).flatten.any? {|a| "bar/bas" == a.path}
  end
  
  def test_asset_2
    Rails.application.expansions do
      expansion :foo do
        `bas/bar.js`
      end
    end
  
    assert Rails.application.expansions.javascripts.has_expansion?(:foo)
    assert_equal :js, Rails.application.expansions.javascripts[:foo].type
    assert Rails.application.expansions.javascripts.all.map(&:assets).flatten.any? {|a| "bar/bas.js" == a.path}
  end
  
  def test_asset_3
    Rails.application.expansions do
      asset "bas/bar", :expansion_name => :foo, :type => :js
    end
  
    assert Rails.application.expansions.javascripts.has_expansion?(:foo)
    assert_equal :js, Rails.application.expansions.javascripts[:foo].type
    assert Rails.application.expansions.javascripts.all.map(&:assets).flatten.any? {|a| "bar/bas" == a.path}
  end
  
  def test_asset_4
    Rails.application.expansions do
      asset "bas/bar.js", :expansion_name => :foo
    end
  
    assert Rails.application.expansions.javascripts.has_expansion?(:foo)
    assert_equal :js, Rails.application.expansions.javascripts[:foo].type
    assert Rails.application.expansions.javascripts.all.map(&:assets).flatten.any? {|a| "bar/bas.js" == a.path}
  end
  
  def test_asset_5
    Rails.application.expansions do
      js do
        asset "bas/bar", :expansion_name => :foo
      end
    end
  
    assert Rails.application.expansions.javascripts.has_expansion?(:foo)
    assert_equal :js, Rails.application.expansions.javascripts[:foo].type
    assert Rails.application.expansions.javascripts.all.map(&:assets).flatten.any? {|a| "bar/bas" == a.path}
  end
  
  def test_asset_6
    Rails.application.expansions do
      css do
        asset "bas/bar", :expansion_name => :foo
      end
    end
  
    assert Rails.application.expansions.stylesheets.has_expansion?(:foo)
    assert_equal :css, Rails.application.expansions.stylesheets[:foo].type
    assert Rails.application.expansions.stylesheets.all.map(&:assets).flatten.any? {|a| "bar/bas" == a.path}
  end

  def test_asset_7
    assert Rails.application.expansions.javascripts.has_expansion?(:jazz)
    assert Rails.application.expansions.stylesheets.has_expansion?(:jazz)
  end

  def test_asset_8
    assert Rails.application.expansions.javascripts.has_expansion?(:dev)
    assert Rails.application.expansions.stylesheets.has_expansion?(:dev)
  end

  def test_asset_9
    assert_raise ActiveAssets::ActiveExpansions::Asset::InvalidAssetType do
      Rails.application.expansions do
        expansion :foo do
          `bas/bar.pdf`
        end
      end
    end
  end

  def test_asset_10
    assert_raise ActiveAssets::ActiveExpansions::Asset::AmbiguousContext do
      Rails.application.expansions do
        expansion :foo do
          `vendor/jquery.mousewheel`
        end
      end
    end
  end

  def test_expansion_1
    Rails.application.expansions do
      expansion :foo do
        `vendor/jquery.mousewheel.js`
      end

      expansion :foo do
        `bar/bas.js`
      end
    end

    assert_equal %w{vendor/jquery.mousewheel.js bar/bas.js}, Rails.application.expansions.javascripts[:foo].assets.map(&:path)
  end

end
