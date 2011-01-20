require 'rake/testtask'
require 'bundler'
require 'bundler/setup'
Bundler::GemHelper.install_tasks

Rake::TestTask.new(:test) do |t|
  t.libs << "test"
  t.pattern = 'test/**/*_test.rb'
  t.verbose = true
end

task :environment do
  load 'test/fixtures/rails_root/config/environment.rb'
end

Dir['lib/tasks/**/*.rake'].each {|f| load f}

task :default => :test
