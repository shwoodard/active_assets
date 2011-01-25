require 'helper'
require 'fileutils'

class Pixmap
  def ==(a_bitmap)
    return false if @width != a_bitmap.width or @height != a_bitmap.height
    @width.times do |x|
      @height.times do |y| 
        return false if not self[x,y] == (a_bitmap[x,y])
      end
    end
    true
  end
end

class RGBColourTest < Test::Unit::TestCase
  def test_init
    color = RGBColour.new(0,100,200)
    assert_equal(100, color.g)
  end
  def test_constants
    assert_equal([255,0,0], [RGBColour::RED.r,RGBColour::RED.g,RGBColour::RED.b])
    assert_equal([0,255,0], [RGBColour::GREEN.r,RGBColour::GREEN.g,RGBColour::GREEN.b])
    assert_equal([0,0,255], [RGBColour::BLUE.r,RGBColour::BLUE.g,RGBColour::BLUE.b])
  end
  def test_error
    color = RGBColour.new(0,100,200)
    assert_raise(ArgumentError) {RGBColour.new(0,0,256)}
  end
end

class PixmapTest < Test::Unit::TestCase
  def setup
    @w = 20
    @h = 30
    @bitmap = Pixmap.new(@w,@h)
  end

  def teardown
    Dir[File.expand_path('../fixtures/*.ppm', __FILE__)].each do |f|
      FileUtils.rm(f)
    end
  end

  def test_init
    assert_equal(@w, @bitmap.width)
    assert_equal(@h, @bitmap.height)
    assert_equal(RGBColour::WHITE, @bitmap.get_pixel(10,10))
  end
  def test_fill
    @bitmap.fill(RGBColour::RED)
    assert_equal(255,@bitmap[10,10].red)
    assert_equal(0,@bitmap[10,10].green)
    assert_equal(0,@bitmap[10,10].blue)
  end
  def test_get_pixel
    assert_equal(@bitmap[5,6], @bitmap.get_pixel(5,6))
    assert_raise(ArgumentError) {@bitmap[100,100]}
  end
  def test_grayscale
    @bitmap.fill(RGBColour::BLUE)
    @bitmap.height.times {|y| [9,10,11].each {|x| @bitmap[x,y]=RGBColour::GREEN}}
    @bitmap.width.times  {|x| [14,15,16].each {|y| @bitmap[x,y]=RGBColour::GREEN}}
    @bitmap.save(File.expand_path('../fixtures/testcross.ppm', __FILE__))
    Pixmap.open(File.expand_path('../fixtures/testcross.ppm', __FILE__)).to_grayscale.save(File.expand_path('../fixtures/testgray.ppm', __FILE__))
  end
  def test_save
    @bitmap.fill(RGBColour::BLUE)
    filename = File.expand_path('../fixtures/test.ppm', __FILE__)
    @bitmap.save(filename)
    expected_size = 3 + (@w.to_s.length + 1 + @h.to_s.length + 1) + 4 + (@w * @h * 3)
    assert_equal(expected_size, File.size(filename))
  end 
  def test_open
    @bitmap.fill(RGBColour::RED)
    @bitmap.set_pixel(10,15, RGBColour::WHITE)
    filename = File.expand_path('../fixtures/test.ppm', __FILE__)
    @bitmap.save(filename)
    new = Pixmap.open(filename)
    assert(@bitmap == new)
  end
end
