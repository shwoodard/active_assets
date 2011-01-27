desc "Generate sprites."
task :sprites => :environment do
  p "Using: #{Rails.application.config.active_sprites.sprite_backend}" if ENV['DEBUG']
  t = Time.now if ENV['DEBUG']
  Rails.application.sprites.generate!
  p "#{Time.now - t}s" if ENV['DEBUG']
end
