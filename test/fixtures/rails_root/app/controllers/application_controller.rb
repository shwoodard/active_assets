class ApplicationController < ActionController::Base
  extend ActiveAssets::ActiveExpansions::Reload

  def index
    head :ok
  end
end
