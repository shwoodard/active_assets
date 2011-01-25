# -*- encoding: utf-8 -*-
Gem::Specification.new do |s|
  s.name        = "active_assets"
  s.version     = '0.2.1'
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Sam Woodard"]
  s.email       = ["sam@wildfireapp.com"]
  s.homepage    = "http://github.com/shwoodard/active_assets"
  s.summary     = %q{A Railtie that provides a full asset management system, including support for development and deployment.}
  s.description = %q{A Railtie that provides a full asset management system, including support for development and deployment.  It is comprised of two libraries, ActiveSprites and ActiveExpansions.  ActiveSprites generates sprites and their corresponding stylesheet from dsl definition. ActiveExpansions manages javascript and css, including concatenation support for deployment, using Rails expansions plus a dsl.}

  s.rubyforge_project = "activeassets"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_development_dependency 'rmagick'
  s.add_development_dependency 'css_parser', '~>1.1.5'
  s.add_development_dependency "rails", "~>3.0.3"
  s.add_development_dependency "test-unit", "> 2.0"
  s.add_development_dependency "ZenTest", "~>4.4.2"
end
