require 'action_controller'
require 'action_view'
require 'rack/mount'
require 'action_view'
require 'fileutils'

module ActiveAssets
  module ActiveSprites
    class AbstractRunner
      class AssetContext < ActionView::Base
      end

      def initialize(railtie, sprites)
        @railtie = railtie
        setup_context
        @sprites = if ENV['SPRITE']
          sprites.select do |name, sprite|
            ENV['SPRITE'].split(',').map(&:strip).any? do |sp|
              # were going to be very forgiving
              name == sp ||
              name == sp.to_sym ||
              name == ::Rack::Mount::Utils.normalize_path(sp)
            end
          end.map(&:last)
        else
          sprites.values
        end
      end

      def generate!
        verbose = ENV['VERBOSE'] != 'false' || ENV['DEBUG']

        if verbose
          t = Time.now
          $stdout << "#{t}: Active Sprites: \"I'm string my run using #{runner_name}.\"\n" 
          $stdout << "\nSprites to create:\n\"#{@sprites.map(&:path).join('", "')}\"\n"
        end

        @sprites.each do |sprite|
          next if sprite.sprite_pieces.empty?

          if verbose
            t_sprite = Time.now
            $stdout << "\n=================================================\n"
            $stdout << "Starting Sprite, #{sprite.path}\n"
          end

          sprite_path = sanitize_asset_path(context.image_path(sprite.path))
          sprite_stylesheet_path = sanitize_asset_path(context.stylesheet_path(sprite.stylesheet_path))

          orientation = sprite.orientation.to_s
          sprite_pieces = sprite.sprite_pieces

          begin
            $stdout << "Gathering sprite details..." if verbose
            image_list, width, height = set_sprite_details_and_return_image_list(sprite, sprite_path, sprite_pieces, orientation)
            $stdout << "done.\n" if verbose

            if ENV['DEBUG']
              $stdout << "|\tpath\t|\tselectors\t|\tx\t|\ty\t|\twidth\t|\theight\t|\n"
              $stdout << "#{sprite_pieces.map(&:to_s).join("\n")}\n"
            end

            stylesheet = SpriteStylesheet.new(sprite_pieces)
            stylesheet_file_path = File.join(@railtie.config.paths.public.to_a.first, sprite_stylesheet_path)
            $stdout << "Writing stylesheet to #{stylesheet_file_path} ... " if verbose
            stylesheet.write stylesheet_file_path
            $stdout << "done.\n" if verbose

            $stdout << "Beginning sprite generation using #{runner_name.humanize}.\n" if verbose
            create_sprite(sprite, sprite_path, sprite_pieces, image_list, width, height, orientation, verbose)
            $stdout << "Success!\n" if verbose

            sprite_file_path = File.join(@railtie.config.paths.public.to_a.first, sprite_path)
            $stdout << "Writing sprite to #{sprite_file_path} ... " if verbose
            write sprite_file_path, sprite.quality
            $stdout << "done.\n" if verbose

            $stdout << "Finished #{sprite.path} in #{Time.now - t_sprite} seconds.\n" if verbose
            $stdout << "=================================================\n\n" if verbose
          ensure
            finish
          end
        end

        $stdout << "#{Time.now}: ActiveSprites \"I finished my run in #{Time.now - t} seconds.\"\n" if verbose
      end

      private
        def image_full_path(path)
          File.join(@railtie.config.paths.public.to_a.first, sanitize_asset_path(context.image_path(path)))
        end

        def context
          @context
        end

        def sanitize_asset_path(path)
          path.split('?').first
        end

        def setup_context
          unless @railtie.config.respond_to?(:action_controller)
            @railtie.config.action_controller = ActiveSupport::OrderedOptions.new

            paths   = @railtie.config.paths
            options = @railtie.config.action_controller

            options.assets_dir           ||= paths.public.to_a.first
            options.javascripts_dir      ||= paths.public.javascripts.to_a.first
            options.stylesheets_dir      ||= paths.public.stylesheets.to_a.first

            ActiveSupport.on_load(:action_controller) do
              options.each { |k,v| send("#{k}=", v) }
            end
          end

          controller = ActionController::Base.new
          @context = AssetContext.new(@railtie.config.action_controller, {}, controller)
        end

    end
  end
end
