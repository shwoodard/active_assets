desc "Generate sprites."
task :sprites => :environment do
  ENV['VERBOSE'] ||= 'true'
  Rails.application.sprites.generate!
end
