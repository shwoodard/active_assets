# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)

Gem::Specification.new do |s|
  s.name        = "active_assets"
  s.version     = '3.0.3'
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Sam Woodard"]
  s.email       = ["sam@wildfireapp.com"]
  s.homepage    = ""
  s.summary     = %q{A Railtie that provides a full asset management system, including support for development and deployment.}
  s.description = %q{A Railtie that provides a full asset management system, including support for development and deployment.  Currently it is designed to manage javascripts and stylesheets but will handle image sprites in the future.}

  s.rubyforge_project = "rails-assets"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib", "lib/actionpack"]

  s.add_development_dependency "rails", "3.0.3"
end
