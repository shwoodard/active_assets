Active Assets
=============

A Railtie that provides a full asset management system, including support for development and deployment.  This includes building sprites, concatenating javascript and css via expansion definitions.  Active Assets includes two libraries, Active Expansions and Active Sprites.

    gem install active_assets

Gemfile
-------

    gem 'active_assets'

In your rails app
-----------------
### application.rb

    ...
    require 'rails/all'
    require 'active_assets/railtie'
    ...

## The dsls
### Introduction to Active Expansions

Active expansions allow you to register Rails javascript and stylesheet expansions via a simple dsl.  Addionally, the assets in the expansion are concatenated when appropriate and the expansion delivers the concatenated (or 'cached') assets' path in the appropriate environments.  Also, files can be specified as deploy only or only for a specific environment.  For example, you may wish to include jQuery or Prototype src files in development and use minified libraries from cdn sources in production.  This is supported.

* Below demonstration shows several variations on how to declare expansions.  Note that these declaration are redundant to demonstrate how to accomplish the same thing in different ways.
* Alternatively you can also register your assets in multiple files.  Simply omit `config/asets.rb` and add as many .rb files as you like inside a directory `config/assets`
* Note the `register` is optional `Rails.application.expansions do` will work the same way

#### config/assets.rb

    Rails.application.expansions.register do
      expansion :global, :type => :js do
        `vendor/jquery`
        `application`
      end

      expansion :global, :type => :css do
        `vendor/reset`
        `application`
      end

      js do
        expansion :global do
          `vendor/jquery`
          `application`
        end
      end

      css do
        expansion :global do
          `vendor/reset`
          `application`
        end
      end

      expansion :global do
        js do
          `vendor/jquery`
          `application`
        end

        css do
          `vendor/reset`
          `application`
        end
      end
    end

#### config/assets/js.rb (suggestion only)
    Rails.application.expansions.js do
      expansion :global do
        `vendor/jquery`
        `application`
      end
    end

#### config/assets/css.rb (suggestion only)
    Rails.application.expansions.css do
      expansion :global do
        `vendor/reset`
        `application`
      end
    end
