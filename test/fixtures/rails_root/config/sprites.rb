Rails.application.sprites do
  sprite 'sprites/3.png' => 'sprites/3.css' do
    _"sprite_images/sprite3/1.gif" => ".klass_1"
    _"sprite_images/sprite3/2.gif" => ".klass_2"
  end

  sprite 'sprites/4.png' do
    Dir[Rails.root.join('public/images/sprite_images/sprite4/*.{png,gif,jpg}')].each do |path|
      image_path = path[%r{^.*/public/images/(.*)$}, 1]
      klass_name = ".klass_#{File.basename(image_path, File.extname(image_path)).split(' ').join('_').downcase}"
      sp image_path => klass_name
    end
  end
end
