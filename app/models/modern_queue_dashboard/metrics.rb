# frozen_string_literal: true

module ModernQueueDashboard
  Metric = Struct.new(:key, :label, :value, keyword_init: true)

  class Metrics
    class << self
      def summary
        [
          Metric.new(key: :pending,   label: "Pending",   value: pending_count),
          Metric.new(key: :scheduled, label: "Scheduled", value: scheduled_count),
          Metric.new(key: :running,   label: "Running",   value: running_count),
          Metric.new(key: :failed,    label: "Failed",    value: failed_count),
          Metric.new(key: :completed, label: "Completed", value: completed_count),
          Metric.new(key: :latency,   label: "Latency",   value: latency_seconds)
        ]
      end

      private

      def pending_count
        SolidQueue::Job.where("run_at <= ?", Time.current).count
      end

      def scheduled_count
        SolidQueue::Job.where("run_at > ?", Time.current).count
      end

      def running_count
        SolidQueue::Execution.where(finished_at: nil).count
      end

      def failed_count
        SolidQueue::FailedExecution.count
      end

      def completed_count
        SolidQueue::Execution.where.not(finished_at: nil).count
      end

      def latency_seconds
        oldest = SolidQueue::Job.order(:created_at).limit(1).pick(:created_at)
        return 0 unless oldest

        (Time.current - oldest).to_i
      end
    end
  end
end
