require 'rubygems'
require 'active_support/core_ext'
require 'sinatra/base'

class ActiveAssetsTestApp < Sinatra::Base
  set :root, File.dirname(__FILE__)

  get '/sprite' do
    @sprite_path = params[:sprite_path]
    erb :sprite
  end
end
