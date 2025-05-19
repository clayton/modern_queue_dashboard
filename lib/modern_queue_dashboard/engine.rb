# frozen_string_literal: true

require "rails/engine"
require "tailwindcss-rails" if defined?(TailwindCss)

module ModernQueueDashboard
  class Engine < ::Rails::Engine
    isolate_namespace ModernQueueDashboard

    # Set up paths for models
    config.paths.add "app/models", eager_load: true

    # Precompile CSS & JS builds that ship with the gem
    initializer "modern_queue_dashboard.assets" do |app|
      # Check if the app uses the asset pipeline that requires explicit precompilation
      if app.config.respond_to?(:assets) && app.config.assets.respond_to?(:precompile)
        app.config.assets.precompile += %w[modern_queue_dashboard.css modern_queue_dashboard.js]
      end

      # Configure paths for Tailwind CSS if available
      if defined?(TailwindCss) && app.config.respond_to?(:tailwindcss)
        app.config.tailwindcss.content_root = root.join("app").to_s
        app.config.tailwindcss.content_includes = [ "./views/**/*.html.erb", "./helpers/**/*.rb" ]
      end
    end
  end
end
