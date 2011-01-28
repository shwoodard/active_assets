require 'fileutils'
require 'rmagick'
require 'css_parser'

module AbstractRunnerTest
  include Magick
  def runner_setup
    initialize_application_or_load_sprites!

    assert_false Rails.application.sprites.all.empty?

    assert_nothing_raised do
      Rails.application.sprites.generate!
    end

    assert File.exists?(Rails.root.join('public/images/sprites/3.png'))
    assert File.exists?(Rails.root.join('public/images/sprites/4.png'))

    assert File.exists?(Rails.root.join('public/stylesheets/sprites/3.css'))
    assert File.exists?(Rails.root.join('public/stylesheets/sprites/4.css'))
  end

  def teardown
    FileUtils.rm_rf(Rails.root.join('public/images/sprites'))
    FileUtils.rm_rf(Rails.root.join('public/stylesheets/sprites'))

    tear_down_assets
  end

  Selector = Struct.new(:selector, :x, :y, :width, :height)

  def test_generate
    sprite = Rails.application.sprites['sprites/4.png']
    orientation = sprite.orientation
    sprite_pieces = sprite.sprite_pieces
    sprite_image = Image.read(Rails.root.join('public/images', sprite.path)).first

    stylesheet_path = Rails.root.join('public/stylesheets', sprite.stylesheet_path)
    parser = CssParser::Parser.new
    parser.load_file!(File.basename(stylesheet_path), File.dirname(stylesheet_path), :screen)

    sprite_pieces_with_selector_data = []

    parser.each_rule_set do |rs|
      sprite_piece = sprite_pieces.find {|sp| rs.selectors.include?(sp.css_selector) }
      width = rs['width'][%r{\s*(\d+)(?:px)?;?$}, 1].to_i
      height = rs['height'][%r{\s*(\d+)(?:px)?;?$}, 1].to_i
      background = rs['background'][%r{\s*([^;]+)}, 1]
      x = background[%r{\s-?(\d+)(?:px)?\s}, 1].to_i
      y = background[%r{\s-?(\d+)(?:px)?$}, 1].to_i
      sprite_pieces_with_selector_data << [sprite_piece, Selector.new(rs.selectors, x, y, width, height)]
    end

    sprite_pieces_with_selector_data.each do |sp, selector_data|
      begin
        sprite_piece_path = Rails.root.join('public/images', sp.path)
        sprite_piece_image = Image.read(sprite_piece_path).first
        curr_sprite_image = sprite_image.crop(
          selector_data.x,
          selector_data.y,
          selector_data.width,
          selector_data.height
        )
        pd = curr_sprite_image.compare_channel(sprite_piece_image, MeanSquaredErrorMetric).last
        assert_equal 0, pd
      ensure
        sprite_piece_image.destroy! if sprite_piece_image
        curr_sprite_image.destroy! if curr_sprite_image
        curr_sprite_image = nil
        sprite_piece_image = nil
      end
    end
  ensure
    sprite_image.destroy! if sprite_image
    sprite_image = nil
  end
end
