# -*- encoding: utf-8 -*-
Gem::Specification.new do |s|
  s.name        = "active_assets"
  s.version     = '1.0.3'
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Sam Woodard"]
  s.email       = ["sam@wildfireapp.com"]
  s.homepage    = "http://github.com/shwoodard/active_assets"
  s.summary     = %q{A Railtie that provides an asset management system for css, javascript, and sprites in your Rails applications and engines.}
  s.description = %q{A Railtie that provides an asset management system for css, javascript, and sprites in your Rails applications and engines. ActiveAssets includes two libraries, ActiveExpansions and ActiveSprites. ActiveSprites generates sprites defined by a dsl similar to a route definition. Similarly, ActiveExpansions' dsl creates ActionView::Helpers::AssetTagHelper javascript and stylesheet expansions, and adds additional features}

  s.rubyforge_project = "activeassets"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_development_dependency 'oily_png'
  s.add_development_dependency 'chunky_png'
  s.add_development_dependency 'rmagick'
  s.add_development_dependency 'mini_magick'
  s.add_development_dependency 'css_parser', '~>1.1.5'
  s.add_development_dependency "rails", "~>3.0.3"
  s.add_development_dependency "test-unit", "> 2.0"
  s.add_development_dependency "ZenTest", "~>4.4.2"
end
