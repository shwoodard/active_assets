desc "Generate sprites."
task :sprites => :environment do
  Rails.application.sprites.generate!
end
