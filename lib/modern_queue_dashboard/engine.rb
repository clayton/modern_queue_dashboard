# frozen_string_literal: true

require "rails/engine"

module ModernQueueDashboard
  class Engine < ::Rails::Engine
    isolate_namespace ModernQueueDashboard

    # Precompile Tailwind CSS & JS builds that ship with the gem
    initializer "modern_queue_dashboard.assets" do |app|
      # Check if the app uses the asset pipeline that requires explicit precompilation
      if app.config.respond_to?(:assets) && app.config.assets.respond_to?(:precompile)
        app.config.assets.precompile += %w[modern_queue_dashboard.css modern_queue_dashboard.js]
      end
    end
  end
end
