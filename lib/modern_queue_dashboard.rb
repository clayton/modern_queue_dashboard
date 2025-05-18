# frozen_string_literal: true

require_relative "modern_queue_dashboard/version"
require_relative "modern_queue_dashboard/engine"

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
  # Your code goes here...
end
