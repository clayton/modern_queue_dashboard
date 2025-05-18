# frozen_string_literal: true

require "rails/engine"

module ModernQueueDashboard
  class Engine < ::Rails::Engine
    isolate_namespace ModernQueueDashboard

    # Precompile Tailwind CSS & JS builds that ship with the gem
    initializer "modern_queue_dashboard.assets" do |app|
      app.config.assets.precompile += %w[modern_queue_dashboard.css modern_queue_dashboard.js]
    end
  end
end
