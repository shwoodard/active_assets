require 'test_helper'
require 'fileutils'

class ApplicationControllerTest < ActionController::TestCase
  include FileUtils

  def new_assets
    File.expand_path('../../../config/assets/new.rb', __FILE__)
  end

  def write_new_assets
    File.open(new_assets, 'w+') do |io|
      io.puts <<-EOF
        Rails.application.expansions do
          expansion :new do
            _'foo.js'
          end
        end
      EOF
    end
  end

  def teardown
    rm_rf new_assets
    ActionView::Helpers::AssetTagHelper.javascript_expansions.delete(:new)
  end

  def test_index
    get :index
    assert response.success?
  end

  def test_expansions
    assert ActionView::Helpers::AssetTagHelper.javascript_expansions.any? {|k, v| k == :basfoo}
  end

  def test_can_add_expansion
    assert !ActionView::Helpers::AssetTagHelper.javascript_expansions.any? {|k, v| k == :new}
    get :index
    write_new_assets
    get :index
    assert ActionView::Helpers::AssetTagHelper.javascript_expansions.any? {|k, v| k == :new}
  end

  def test_can_remove_expansion
    test_can_add_expansion
    rm_rf new_assets
    get :index
    
    assert !ActionView::Helpers::AssetTagHelper.javascript_expansions.any? {|k, v| k == :new}
  end
end
