# frozen_string_literal: true

require "rails"
require "action_controller/railtie"
require "active_support/dependencies"
require_relative "modern_queue_dashboard/version"

module ModernQueueDashboard
  class Error < StandardError; end

  class Configuration
    attr_accessor :refresh_interval, :time_zone

    def initialize
      @refresh_interval = 5
      @time_zone = "UTC"
    end
  end

  class << self
    attr_writer :configuration

    def configuration
      @configuration ||= Configuration.new
    end

    def configure
      yield(configuration)
    end
  end
end

# Load engine which will handle autoloading of app files
require_relative "modern_queue_dashboard/engine"

# Explicitly require models for compatibility
require_relative "../app/models/modern_queue_dashboard/queue_summary"
require_relative "../app/models/modern_queue_dashboard/metrics"
