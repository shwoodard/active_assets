###########################################################################
# Represents an RGB[http://en.wikipedia.org/wiki/Rgb] colour.  
class RGBColour
  # Red, green and blue values must fall in the range 0..255.
  def initialize(red, green, blue)
    ok = [red, green, blue].inject(true) {|ok,c| ok &= c.between?(0,255)}
    unless ok
      raise ArgumentError, "invalid RGB parameters: #{[red, green, blue].inspect}"
    end
    @red, @green, @blue = red, green, blue
  end
  attr_reader :red, :green, :blue
  alias_method :r, :red
  alias_method :g, :green
  alias_method :b, :blue

  # the difference between two colours
  def -(a_colour)
    (@red - a_colour.red).abs +
    (@green - a_colour.green).abs +
    (@blue - a_colour.blue).abs
  end

  # Return the list of [red, green, blue] values.
  #     RGBColour.new(100,150,200).values # => [100, 150, 200]
  # call-seq:
  # values -> array
  #
  def values
    [@red, @green, @blue]
  end

  # Equality test: two RGBColour objects are equal if they have the same
  # red, green and blue values.
  # call-seq:
  #     ==(a_colour) -> true or false
  #
  def ==(a_colour)
    values == a_colour.values
  end

  # Comparison test: compares two RGBColour objects based on their #luminosity value
  # call-seq:
  #     <=>(a_colour) -> -1, 0, +1
  #
  def <=>(a_colour)
    self.luminosity <=> a_colour.luminosity
  end

  # Calculate a integer luminosity value, in the range 0..255
  #     RGBColour.new(100,150,200).luminosity # => 142
  # call-seq:
  #     luminosity -> int
  #
  def luminosity
    Integer(0.2126*@red + 0.7152*@green + 0.0722*@blue)
  end

  # Return a new RGBColour value where all the red, green, blue values are the
  # #luminosity value.
  #     RGBColour.new(100,150,200).to_grayscale.values # => [142, 142, 142]
  # call-seq:
  #     to_grayscale -> a_colour
  #
  def to_grayscale
    l = luminosity
    self.class.new(l, l, l)
  end

  # Return a new RGBColour object given an iteration value for the Pixmap.mandelbrot
  # method.
  def self.mandel_colour(i)
    self.new( 16*(i % 15), 32*(i % 7), 8*(i % 31) )
  end

  RED   = RGBColour.new(255,0,0)
  GREEN = RGBColour.new(0,255,0)
  BLUE  = RGBColour.new(0,0,255)
  YELLOW= RGBColour.new(255,255,0)
  BLACK = RGBColour.new(0,0,0)
  WHITE = RGBColour.new(255,255,255)
end

###########################################################################
# A Pixel represents an (x,y) point in a Pixmap.
Pixel = Struct.new(:x, :y)

###########################################################################
class Pixmap
  def initialize(width, height)
    @width = width
    @height = height
    @data = fill(RGBColour::WHITE)
  end
  attr_reader :width, :height

  def fill(colour)
    @data = Array.new(@width) {Array.new(@height, colour)}
  end

  def -(a_pixmap)
    if @width != a_pixmap.width or @height != a_pixmap.height
      raise ArgumentError, "can't compare images with different sizes"
    end
    sum = 0
    each_pixel {|x,y| sum += self[x,y] - a_pixmap[x,y]}
    Float(sum) / (@width * @height * 255 * 3)
  end

  def validate_pixel(x,y)
    unless x.between?(0, @width-1) and y.between?(0, @height-1)
      raise ArgumentError, "requested pixel (#{x}, #{y}) is outside dimensions of this bitmap"
    end
  end

  ###############################################
  def [](x,y)
    validate_pixel(x,y)
    @data[x][y]
  end
  alias_method :get_pixel, :[]

  def []=(x,y,colour)
    validate_pixel(x,y)
    @data[x][y] = colour
  end
  alias_method :set_pixel, :[]=

  def each_pixel
    if block_given?
      @height.times {|y| @width.times {|x| yield x,y}}
    else
      to_enum(:each_pixel)
    end
  end

  ###############################################
  # write to file/stream
  PIXMAP_FORMATS = ["P3", "P6"]   # implemented output formats
  PIXMAP_BINARY_FORMATS = ["P6"]  # implemented output formats which are binary

  def write_ppm(ios, format="P6")
    if not PIXMAP_FORMATS.include?(format)
      raise NotImplementedError, "pixmap format #{format} has not been implemented" 
    end
    ios.puts format, "#{@width} #{@height}", "255"
    ios.binmode if PIXMAP_BINARY_FORMATS.include?(format)
    @height.times do |y|
      @width.times do |x|
        case format
        when "P3" then ios.print @data[x][y].values.join(" "),"\n"
        when "P6" then ios.print @data[x][y].values.pack('C3')
        end
      end
    end
  end

  def save(filename, opts={:format=>"P6"})
    File.open(filename, 'w') do |f|
      write_ppm(f, opts[:format])
    end
  end
  alias_method :write, :save

  def print(opts={:format=>"P6"})
    write_ppm($stdout, opts[:format])
  end

  def save_as_jpeg(filename, quality=75)
    # using the ImageMagick convert tool
    begin
      pipe = IO.popen("convert ppm:- -quality #{quality} jpg:#{filename}", 'w')
      write_ppm(pipe)
    rescue SystemCallError => e
      warn "problem writing data to 'convert' utility -- does it exist in your $PATH?"
    ensure
      pipe.close rescue false
    end
  end

  ###############################################
  # read from file/pipe
  def self.read_ppm(ios)
    format = ios.gets.chomp
    width, height = ios.gets.chomp.split.map {|n| n.to_i }
    max_colour = ios.gets.chomp

    if (not PIXMAP_FORMATS.include?(format)) or 
        width < 1 or height < 1 or
        max_colour != '255'
    then
      ios.close
      raise StandardError, "file '#{filename}' does not start with the expected header"
    end
    ios.binmode if PIXMAP_BINARY_FORMATS.include?(format)

    bitmap = self.new(width, height)
    height.times do |y|
      width.times do |x|
        # read 3 bytes
        red, green, blue = case format
          when 'P3' then ios.gets.chomp.split
          when 'P6' then ios.read(3).unpack('C3')
        end
        bitmap[x,y] = RGBColour.new(red, green, blue)
      end
    end
    ios.close
    bitmap
  end

  def self.open(filename)
    read_ppm(File.open(filename, 'r'))
  end

  def self.open_from_jpeg(filename)
    unless File.readable?(filename)
      raise ArgumentError, "#{filename} does not exists or is not readable."
    end
    begin
      pipe = IO.popen("convert jpg:#{filename} ppm:-", 'r')
      read_ppm(pipe)
    rescue SystemCallError => e
      warn "problem reading data from 'convert' utility -- does it exist in your $PATH?"
    ensure
      pipe.close rescue false
    end
  end

  ###############################################
  # conversion methods
  def to_grayscale
    gray = self.class.new(@width, @height)
    @width.times do |x|
      @height.times do |y|
        gray[x,y] = self[x,y].to_grayscale
      end
    end
    gray
  end

  ###############################################
  def draw_line(p1, p2, colour)
    validate_pixel(p1.x, p2.y)
    validate_pixel(p2.x, p2.y)

    x1, y1 = p1.x, p1.y
    x2, y2 = p2.x, p2.y

    steep = (y2 - y1).abs > (x2 - x1).abs
    if steep
      x1, y1 = y1, x1
      x2, y2 = y2, x2
    end
    if x1 > x2
      x1, x2 = x2, x1
      y1, y2 = y2, y1
    end

    deltax = x2 - x1
    deltay = (y2 - y1).abs
    error = deltax / 2
    ystep = y1 < y2 ? 1 : -1

    y = y1
    x1.upto(x2) do |x|
      pixel = steep ? [y,x] : [x,y]
      self[*pixel] = colour
      error -= deltay
      if error < 0
        y += ystep
        error += deltax
      end
    end
  end

  ###############################################
  def draw_line_antialised(p1, p2, colour)
    x1, y1 = p1.x, p1.y
    x2, y2 = p2.x, p2.y

    steep = (y2 - y1).abs > (x2 - x1).abs
    if steep
      x1, y1 = y1, x1
      x2, y2 = y2, x2
    end
    if x1 > x2
      x1, x2 = x2, x1
      y1, y2 = y2, y1
    end
    deltax = x2 - x1
    deltay = (y2 - y1).abs
    gradient = 1.0 * deltay / deltax

    # handle the first endpoint
    xend = x1.round
    yend = y1 + gradient * (xend - x1)
    xgap = (x1 + 0.5).rfpart
    xpxl1 = xend
    ypxl1 = yend.truncate
    put_colour(xpxl1, ypxl1, colour, steep, yend.rfpart * xgap)
    put_colour(xpxl1, ypxl1 + 1, colour, steep, yend.fpart * xgap)
    itery = yend + gradient

    # handle the second endpoint
    xend = x2.round
    yend = y2 + gradient * (xend - x2)
    xgap = (x2 + 0.5).rfpart
    xpxl2 = xend
    ypxl2 = yend.truncate
    put_colour(xpxl2, ypxl2, colour, steep, yend.rfpart * xgap)
    put_colour(xpxl2, ypxl2 + 1, colour, steep, yend.fpart * xgap)

    # in between
    (xpxl1 + 1).upto(xpxl2 - 1).each do |x|
      put_colour(x, itery.truncate, colour, steep, itery.rfpart)
      put_colour(x, itery.truncate + 1, colour, steep, itery.fpart)
      itery = itery + gradient
    end
  end

  def put_colour(x, y, colour, steep, c)
    x, y = y, x if steep
    self[x, y] = anti_alias(colour, self[x, y], c)
  end

  def anti_alias(new, old, ratio)
    blended = new.values.zip(old.values).map {|n, o| (n*ratio + o*(1.0 - ratio)).round}
    RGBColour.new(*blended)
  end

  ###############################################
  def draw_circle(pixel, radius, colour)
    validate_pixel(pixel.x, pixel.y)

    self[pixel.x, pixel.y + radius] = colour
    self[pixel.x, pixel.y - radius] = colour
    self[pixel.x + radius, pixel.y] = colour
    self[pixel.x - radius, pixel.y] = colour

    f = 1 - radius
    ddF_x = 1
    ddF_y = -2 * radius
    x = 0
    y = radius
    while x < y
      if f >= 0
        y -= 1
        ddF_y += 2
        f += ddF_y
      end
      x += 1
      ddF_x += 2
      f += ddF_x
      self[pixel.x + x, pixel.y + y] = colour
      self[pixel.x + x, pixel.y - y] = colour
      self[pixel.x - x, pixel.y + y] = colour
      self[pixel.x - x, pixel.y - y] = colour
      self[pixel.x + y, pixel.y + x] = colour
      self[pixel.x + y, pixel.y - x] = colour
      self[pixel.x - y, pixel.y + x] = colour
      self[pixel.x - y, pixel.y - x] = colour
    end
  end

  ###############################################
  def flood_fill(pixel, new_colour)
    current_colour = self[pixel.x, pixel.y]
    queue = RasterQueue.new
    queue.enqueue(pixel)
    until queue.empty?
      p = queue.dequeue
      if self[p.x, p.y] == current_colour
        west = find_border(p, current_colour, :west)
        east = find_border(p, current_colour, :east)
        draw_line(west, east, new_colour)
        q = west
        while q.x <= east.x
          [:north, :south].each do |direction|
            n = neighbour(q, direction)
            queue.enqueue(n) if self[n.x, n.y] == current_colour
          end
          q = neighbour(q, :east)
        end
      end
    end
  end

  def neighbour(pixel, direction)
    case direction
    when :north then Pixel[pixel.x, pixel.y - 1]
    when :south then Pixel[pixel.x, pixel.y + 1]
    when :east  then Pixel[pixel.x + 1, pixel.y]
    when :west  then Pixel[pixel.x - 1, pixel.y]
    end
  end

  def find_border(pixel, colour, direction)
    nextp = neighbour(pixel, direction)
    while self[nextp.x, nextp.y] == colour
      pixel = nextp
      nextp = neighbour(pixel, direction)
    end
    pixel
  end

  ###############################################
  def median_filter(radius=3)
    if radius.even?
      radius += 1
    end
    filtered = self.class.new(@width, @height)


    $stdout.puts "processing #{@height} rows"
    pb = ProgressBar.new(@height) if $DEBUG

    @height.times do |y|
      @width.times do |x|
        window = []
        (x - radius).upto(x + radius).each do |win_x|
          (y - radius).upto(y + radius).each do |win_y|
            win_x = 0 if win_x < 0
            win_y = 0 if win_y < 0
            win_x = @width-1 if win_x >= @width
            win_y = @height-1 if win_y >= @height
            window << self[win_x, win_y]
          end
        end
        # median
        filtered[x, y] = window.sort[window.length / 2]
      end
      pb.update(y) if $DEBUG
    end

    pb.close if $DEBUG

    filtered
  end

  ###############################################
  def histogram
    histogram = Hash.new(0)
    @height.times do |y|
      @width.times do |x|
        histogram[self[x,y].luminosity] += 1
      end
    end
    histogram 
  end

  def to_blackandwhite
    hist = histogram

    # find the median luminosity
    median = nil
    sum = 0
    hist.keys.sort.each do |lum|
      sum += hist[lum]
      if sum > @height * @width / 2
        median = lum
        break
      end
    end

    # create the black and white image
    bw = self.class.new(@width, @height)
    @height.times do |y|
      @width.times do |x|
        bw[x,y] = self[x,y].luminosity < median ? RGBColour::BLACK : RGBColour::WHITE
      end
    end
    bw
  end

  def save_as_blackandwhite(filename)
    to_blackandwhite.save(filename)
  end

  ###############################################
  def draw_bezier_curve(points, colour)
    # ensure the points are increasing along the x-axis
    points = points.sort_by {|p| [p.x, p.y]}
    xmin = points[0].x
    xmax = points[-1].x
    increment = 2
    prev = points[0]
    ((xmin + increment) .. xmax).step(increment) do |x|
      t = 1.0 * (x - xmin) / (xmax - xmin)
      p = Pixel[x, bezier(t, points).round]
      draw_line(prev, p, colour)
      prev = p
    end
  end

  # the generalized n-degree Bezier summation
  def bezier(t, points)
    n = points.length - 1
    points.each_with_index.inject(0.0) do |sum, (point, i)|
      sum += n.choose(i) * (1-t)**(n - i) * t**i * point.y
    end
  end

  ###############################################
  def self.mandelbrot(width, height)
    mandel = Pixmap.new(width,height)
    pb = ProgressBar.new(width) if $DEBUG
    width.times do |x|
      height.times do |y|
        x_ish = Float(x - width*11/15) / (width/3)
        y_ish = Float(y - height/2) / (height*3/10)
        mandel[x,y] = RGBColour.mandel_colour(mandel_iters(x_ish, y_ish))
      end
      pb.update(x) if $DEBUG
    end
    pb.close if $DEBUG
    mandel
  end

  def self.mandel_iters(cx,cy)
    x = y = 0.0
    count = 0
    while Math.hypot(x,y) < 2 and count < 255
      x, y = (x**2 - y**2 + cx), (2*x*y + cy)
      count += 1
    end
    count
  end 

  ###############################################
  # Apply a convolution kernel to a whole image
  def convolute(kernel)
    newimg = Pixmap.new(@width, @height)
    pb = ProgressBar.new(@width) if $DEBUG
    @width.times do |x|
      @height.times do |y|
        apply_kernel(x, y, kernel, newimg)
      end
      pb.update(x) if $DEBUG
    end
    pb.close if $DEBUG
    newimg
  end

  # Applies a convolution kernel to produce a single pixel in the destination
  def apply_kernel(x, y, kernel, newimg)
    x0 = [0, x-1].max
    y0 = [0, y-1].max
    x1 = x
    y1 = y
    x2 = [@width-1, x+1].min
    y2 = [@height-1, y+1].min

    r = g = b = 0.0
    [x0, x1, x2].zip(kernel).each do |xx, kcol|
      [y0, y1, y2].zip(kcol).each do |yy, k|
        r += k * self[xx,yy].r
        g += k * self[xx,yy].g
        b += k * self[xx,yy].b
	    end
    end
    newimg[x,y] = RGBColour.new(luma(r), luma(g), luma(b))
  end

  # Function for clamping values to those that we can use with colors
  def luma(value)
    if value < 0
      0
    elsif value > 255
      255
    else
      value
    end
  end
end


###########################################################################
# Utilities
class ProgressBar
  def initialize(max)
    $stdout.sync = true
    @progress_max = max
    @progress_pos = 0
    @progress_view = 68
    $stdout.print "[#{'-'*@progress_view}]\r["
  end

  def update(n)
    new_pos = n * @progress_view/@progress_max
    if new_pos > @progress_pos
      @progress_pos = new_pos 
      $stdout.print '='
    end
  end

  def close
    $stdout.puts '=]'
  end
end

class RasterQueue < Array
  alias_method :enqueue, :push
  alias_method :dequeue, :shift
end

class Numeric
  def fpart
    self - self.truncate
  end
  def rfpart
    1.0 - self.fpart
  end
end

class Integer
  def choose(k)
    self.factorial / (k.factorial * (self - k).factorial)
  end
  def factorial
    (2 .. self).reduce(1, :*)
  end
end
