# frozen_string_literal: true

module ModernQueueDashboard
  Metric = Struct.new(:key, :label, :value, keyword_init: true)

  class Metrics
    def self.summary
      [
        Metric.new(key: :pending, label: "Pending", value: count_pending_jobs),
        Metric.new(key: :scheduled, label: "Scheduled", value: count_scheduled_jobs),
        Metric.new(key: :running, label: "Running", value: count_running_jobs),
        Metric.new(key: :failed, label: "Failed", value: count_failed_jobs),
        Metric.new(key: :completed, label: "Completed", value: count_completed_jobs),
        Metric.new(key: :latency, label: "Latency", value: calculate_latency)
      ]
    end

    # These methods are placeholders and will need to be implemented using the SolidQueue models
    def self.count_pending_jobs
      0
    end

    def self.count_scheduled_jobs
      0
    end

    def self.count_running_jobs
      0
    end

    def self.count_failed_jobs
      0
    end

    def self.count_completed_jobs
      0
    end

    def self.calculate_latency
      0
    end
  end
end
