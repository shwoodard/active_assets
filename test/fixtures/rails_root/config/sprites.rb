Rails.application.sprites do
  sprite 'sprites/3.png' => 'sprites/3.css' do
    _"sprite_images/sprite3/1.png" => ".klass_1"
    _"sprite_images/sprite3/2.png" => ".klass_2"
  end
end
