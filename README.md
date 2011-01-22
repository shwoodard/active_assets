Active Assets
=============

A Railtie that provides a full asset management system, including support for development and deployment.  This includes building sprites, concatenating javascript and css via expansion definitions.

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
