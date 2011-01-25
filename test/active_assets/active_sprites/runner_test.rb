require 'helper'
require 'fileutils'
require 'rmagick'

class RunnerTest < Test::Unit::TestCase
  include Magick
  def setup
    initialize_application_or_load_sprites!

    assert_false Rails.application.sprites.all.empty?

    assert_nothing_raised do
      Rails.application.sprites.generate!
    end
  end

  def teardown
    FileUtils.rm_rf(Rails.root.join('public/images/sprites'))
    FileUtils.rm_rf(Rails.root.join('public/stylesheets/sprites'))

    tear_down_assets
  end


  def test_generate
    sprite = Rails.application.sprites['sprites/4.png']
    orientation = sprite.orientation
    sprite_pieces = sprite.sprite_pieces
    sprite_image = Image.read(Rails.root.join('public/images/sprites/4.png')).first
    # TODO parse stylesheet
    offset = 0
    sprite_pieces.each do |sp|
      begin
        sprite_piece_path = Rails.root.join('public/images', sp.path)
        sprite_piece_image = Image.read(sprite_piece_path).first
        curr_sprite_image = sprite_image.crop(
          orientation.to_s == ActiveAssets::ActiveSprites::Sprite::Orientation::VERTICAL ? 0 : offset,
          orientation.to_s == ActiveAssets::ActiveSprites::Sprite::Orientation::VERTICAL ? offset : 0,
          sprite_piece_image.columns,
          sprite_piece_image.rows
        )
        curr_sprite_image_file = Tempfile.new("curr_sprite_img.ppm")
        curr_sprite_image.write "ppm:#{curr_sprite_image_file.path}"
        curr_sprite_piece_image_bmp = Tempfile.new("curr_sprite_piece_image_bmp.ppm")
        sprite_piece_image.write "ppm:#{curr_sprite_piece_image_bmp.path}"
        pd = percent_difference(curr_sprite_image_file.path, curr_sprite_piece_image_bmp.path)
        assert pd <= 0.25
        offset += orientation.to_s == ActiveAssets::ActiveSprites::Sprite::Orientation::VERTICAL ?
          sprite_piece_image.rows : sprite_piece_image.cols
      ensure
        sprite_piece_image.destroy! if sprite_piece_image
        curr_sprite_image.destroy! if curr_sprite_image
        curr_sprite_image_file.close if curr_sprite_image_file
        curr_sprite_piece_image_bmp.close if curr_sprite_piece_image_bmp
        curr_sprite_piece_image_bmp = nil
        curr_sprite_image_file = nil
        curr_sprite_image = nil
        sprite_piece_image = nil
      end
    end
  ensure
    sprite_image.destroy! if sprite_image
    sprite_image = nil
  end
  
  def test_sprite_exists
    assert File.exists?(Rails.root.join('public/images/sprites/3.png'))
    assert File.exists?(Rails.root.join('public/images/sprites/4.png'))
  end
  
  def test_stylesheets_exists
    assert File.exists?(Rails.root.join('public/stylesheets/sprites/3.css'))
    assert File.exists?(Rails.root.join('public/stylesheets/sprites/4.css'))
  end
end
