Active Assets
=============

### Known issue with current versions of ChunkyPng and OliyPng

__In your Rails App's gemfile, if you are using ChunkyPng or ChunkyPng with OilyPng, lock down the version to ChunkyPng(0.12.0), OilyPng(0.3.0)__

If you are looking to use Active Assets with rails 2.3.x, click [here](https://github.com/shwoodard/active_assets/tree/0-3).

A Railtie that provides an asset management system for css, javascript, and sprites in your Rails applications and engines. ActiveAssets includes two libraries, ActiveExpansions and ActiveSprites.  ActiveSprites generates sprites defined by a dsl similar to a route definition.  Similarly, ActiveExpansions' dsl creates `ActionView::Helpers::AssetTagHelper` javascript and stylesheet expansions, and adds additional features:

* Concatenation of included assets for expansions at boot or deploy time.
* Support for environment specific assets, so that, say, you can use one file for development and another for production or one file for development and then a cdn resource for production.

Gemfile
-------

    ...
    gem 'active_assets'
    ...
    group :development do
      ...
      gem 'rmagick'
      ... OR ...
      gem 'oily_png'
      ... OR ...
      gem 'chunky_png'
      ... OR ...
      gem 'mini_magick
    end
    ...

The above order of image libraries is also the load order precedence.

In your Rails app
-----------------
### application.rb

    ...
    require 'rails/all'
    require 'active_assets/railtie'
    ...

#### You can also include only ActiveSprites or only ActiveExpansions in your application
### application.rb
Instead of the above,

    ...
    require 'rails/all'
    require 'active_assets/active_expansions/railtie'
    ... OR ...
    require 'active_assets/active_sprites/railtie'
    ...

The DSLs
========
## Introduction to Active Sprites

ActiveSprites allows you to generate sprites within your Rails apps with `rake sprites`!  All you need is `rmagick`, `chunky_png`, or `mini_magick` and you are on your way. Store the images that make up your sprites within your Rails project, use the dsl below to inform ActiveSprites of which images to include in your sprites as well as the css selector corresponding to each image, the location to write the sprite, and the location to write the stylesheet.

A basic example ...

#### config/sprites.rb
    Rails.application.sprites do
      sprite 'sprites/world_flags.png' => 'sprites/world_flags.css' do
        _"sprite_images/world_flags/Argentina.gif" => ".flags.argentina"
        _"sprite_images/world_flags/Australia.gif" => ".flags.australia"
        ...
      end
    end

#### To generate
    rake sprites
    
or

    Rails.application.sprites.generate!

### More on Active Sprites

It is possible to add all of the world flags!  Haha, see the following example,

    Rails.application.sprites do
      sprite :world_flags do
        Dir[Rails.root.join('public/images/sprite_images/world_flags/*.{png,gif,jpg}')].each do |path|
          image_path = path[%r{^.*/public/images/(.*)$}, 1]
          klass_name = ".flag.#{File.basename(image_path, File.extname(image_path)).split(' ').join('_')}"

          sp image_path => klass_name
        end
      end
    end
`_` and `sp` are aliases for `sprite_piece`

Also, you will notice that I gave a symbol for the sprite instead of a mapping.  This will assume that you wish to store your sprite at `path/to/your/public/images/sprites/world_flags.png` and you wish to store your stylesheet at `path/to/your/public/stylesheets/sprites/world_flags.css`.

#### ActiveSprites configuration 
Rmagick is used by default and is by far the fastest.  You can use one of two methods to select a backend to use.  Simply install any from the list above, and ActiveSprites, will automatically use the one that is available, OR configure ActiveSprites to use a specific backend:

##### config/application.rb

    ...
    config.active_sprites.sprite_backend = :chunky_png
    ...


## Introduction to Active Expansions

ActiveExpansions allow you to register Rails javascript and stylesheet expansions via a simple dsl.  Additionally, the assets in the expansion are concatenated when appropriate and the expansion delivers the concatenated (or 'cached') assets' path in the appropriate environments.  Also, files can be specified as deploy only or only for a specific environment.  For example, you may wish to include jQuery or Prototype src files in development and use minified libraries from cdn sources in production.  This is supported.

* Below demonstration shows several variations on how to declare expansions.  Note that these declaration are redundant to demonstrate how to accomplish the same thing in different ways.
* Alternatively you can also register your assets in multiple files.  Simply omit `config/asets.rb` and add as many .rb files as you like inside a directory `config/assets`
* Note the `register` is optional `Rails.application.expansions do` will work the same way

#### config/assets.rb

    Rails.application.expansions.register do
      expansion :global, :type => :js do
        _'vendor/jquery'
        _'application'
      end

      expansion :global, :type => :css do
        _'vendor/reset'
        _'application'
      end

      expansion :global do
        _'vendor/jquery.js'
        _'application.js'
        _'vendor/reset.css'
        _'application.css'
      end

      js do
        expansion :global do
          _'vendor/jquery'
          _'application'
        end
      end

      css do
        expansion :global do
          _'vendor/reset'
          _'application'
        end
      end

      expansion :global do
        js do
          _'vendor/jquery'
          _'application'
        end

        css do
          _'vendor/reset'
          _'application'
        end
      end
    end

#### config/assets/js.rb (suggestion only)
    Rails.application.expansions.js do
      expansion :global do
        _'vendor/jquery'
        _'application'
      end
    end

#### config/assets/css.rb (suggestion only)
    Rails.application.expansions.css do
      expansion :global do
        _'vendor/reset'
        _'application'
      end
    end

### More on Active Expansions
You can specify certain assets only be used in a deployment setting or only be used in a production setting.  The example below illustrates how to include a library in development and the same library from a cdn in production.  The net result will be that the library will not get cached (concatenated) along with all of the other files because it is specified for use only in development and test.  Hence, the cache file will only be comprised of the other assets in the expansion.  Similarly, the cdn resort will not get cached either but instead will be used directly.  The resulting expansion in production will include two paths, the cdn url to jquery and the path the cache file, in this case, public/{javascript,stylesheets}/cache/global.{js,css}.

    Rails.application.expansions.register do
      expansion :global do
        js do
          asset 'vendor/jquery', :group => [:development, :test]
          asset 'http://ajax.googleapis.com/ajax/libs/jquery/1.4.4/jquery.min.js', :group => :deploy, :cache => false
          _'application'
        end

        css do
          asset 'vendor/reset', :group => [:development, :test]
          asset 'http://ajax.googleapis.com/ajax/libs/yui/2.8.1/build/reset-fonts/reset-fonts.css', :group => :deploy, :cache => false
          _'application'
        end
      end
    end

`_` and `a` are aliases for `asset`

#### ActiveExpansions configuration and deployment
By default, ActiveExpansions will not cache your assets even if `ActionController.perform_caching` is enabled.  This is because if you are not serving assets from the same server as where your application resides, then you most likely want to cache your assets at deploy time (on the front-end servers).  To cache assets manually,

    Rails.application.expansions.javascripts.cache!
    Rails.application.expansions.stylesheets.cache!

To enable your application to cache assets when the application is initialized, i.e. boot time, follow this example,

##### config/environments/production.rb

    ...
    config.active_expansions.precache_assets = true
    ...

Contributing
============
Fork and stuff...you know the drill!
