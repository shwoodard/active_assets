require 'helper'

class ExpansionsTest < Test::Unit::TestCase
  def setup
    Rails.application.config.action_controller.perform_caching = false

    if File.exists?(File.join(rails_root, 'config/assets.rb'))
      load File.join(rails_root, 'config/assets.rb')
    elsif File.directory?(File.join(rails_root, 'config/assets'))
      Dir[File.join(rails_root, 'config/assets/*.rb')].each do |f|
        load f
      end if Rails.application && Rails.application.instance_variable_defined?(:@ran)
    end

    ActiveAssetsTest::Application.initialize! unless Rails.application && Rails.application.instance_variable_defined?(:@ran)
  end

  def teardown
    delete_cached_assets
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
  
    assert Rails.application.expansions.javascripts.has_expansion?(:foo)
    assert_equal :js, Rails.application.expansions.javascripts[:foo].type
  end
  
  def test_asset_2
    Rails.application.expansions do
      expansion :foo do
        `bas/bar.js`
      end
    end
  
    assert Rails.application.expansions.javascripts.has_expansion?(:foo)
    assert_equal :js, Rails.application.expansions.javascripts[:foo].type
  end
  
  def test_asset_3
    Rails.application.expansions do
      asset "bas/bar", :expansion_name => :foo, :type => :js
    end
  
    assert Rails.application.expansions.javascripts.has_expansion?(:foo)
    assert_equal :js, Rails.application.expansions.javascripts[:foo].type
  end
  
  def test_asset_4
    Rails.application.expansions do
      asset "bas/bar.js", :expansion_name => :foo
    end
  
    assert Rails.application.expansions.javascripts.has_expansion?(:foo)
    assert_equal :js, Rails.application.expansions.javascripts[:foo].type
  end
  
  def test_asset_5
    Rails.application.expansions do
      js do
        asset "bas/bar", :expansion_name => :foo
      end
    end
  
    assert Rails.application.expansions.javascripts.has_expansion?(:foo)
    assert_equal :js, Rails.application.expansions.javascripts[:foo].type
  end
  
  def test_asset_6
    Rails.application.expansions do
      css do
        asset "bas/bar", :expansion_name => :foo
      end
    end
  
    assert Rails.application.expansions.stylesheets.has_expansion?(:foo)
    assert_equal :css, Rails.application.expansions.stylesheets[:foo].type
  end

  def test_asset_7
    assert Rails.application.expansions.javascripts.has_expansion?(:jazz)
    assert Rails.application.expansions.stylesheets.has_expansion?(:jazz)
  end

end
