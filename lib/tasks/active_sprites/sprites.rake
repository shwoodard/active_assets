desc "Sprites bitch!"
task :sprites => :environment do
  Rails.application.sprites.generate!
end