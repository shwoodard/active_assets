require 'active_support'

module ActiveAssets
  autoload :ActiveExpansions, 'active_assets/active_expansions'
  autoload :ActiveSprites, 'active_assets/active_sprites'

  def self.rails2?
    rv = Rails.version rescue nil
    rv ||= RAILS_GEM_VERSION rescue nil
    rv ||= Gem.loaded_specs.find { |n,spec| n == 'rails' }[1].version.to_s

    Gem::Version.new(rv) < Gem::Version.new('3.0.0.beta')
  end
end

require 'active_assets/rails2_support' if ActiveAssets.rails2?