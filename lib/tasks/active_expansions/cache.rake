namespace :activeexpansions do
  desc "Cache the active expansions to the {stylesheets,javascripts} cache directory"
  task :cache => :environment do
    Rails.application.expansions.javascripts.cache! and Rails.application.expansions.stylesheets.cache!
  end
end
