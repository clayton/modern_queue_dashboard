# frozen_string_literal: true

module ModernQueueDashboard
  # Represents a single metric
  Metric = Struct.new(:key, :label, :value, keyword_init: true)

  # Provides metrics related to jobs
  class Metrics
    def self.summary
      [
        Metric.new(key: :pending, label: "Pending", value: 0),
        Metric.new(key: :scheduled, label: "Scheduled", value: 0),
        Metric.new(key: :running, label: "Running", value: 0),
        Metric.new(key: :failed, label: "Failed", value: 0),
        Metric.new(key: :completed, label: "Completed", value: 0),
        Metric.new(key: :latency, label: "Avg. Latency", value: 0)
      ]
    end
  end
end
